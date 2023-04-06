#include "standardservicebackend.h"
#include "standardserviceplugin.h"
#include <QtCore/QLockFile>
#ifdef Q_OS_WIN
#include <qt_windows.h>
#else
#include <csignal>
#include <unistd.h>
#endif

using namespace QtService;

Q_LOGGING_CATEGORY(logBackend, "qt.service.plugin.standard.backend")

StandardServiceBackend::StandardServiceBackend(bool debugMode, Service *service) :
	ServiceBackend{service},
	_debugMode{debugMode}
{}

int StandardServiceBackend::runService(int &argc, char **argv, int flags)
{
	//setup logging
	QString filePrefix;
	if (_debugMode)
		filePrefix = Q_T("%{file}:%{line} ");
#ifdef Q_OS_WIN
	qSetMessagePattern(Q_T("[%{time} "
	                       "%{if-debug}Debug]    %{endif}"
	                       "%{if-info}Info]     %{endif}"
	                       "%{if-warning}Warning]  %{endif}"
	                       "%{if-critical}Critical] %{endif}"
	                       "%{if-fatal}Fatal]    %{endif}"
	                       "%1%{if-category}%{category}: %{endif}"
	                       "%{message}").arg(filePrefix));
#else
	qSetMessagePattern(Q_T("[%{time} "
	                       "%{if-debug}\033[32mDebug\033[0m]    %{endif}"
	                       "%{if-info}\033[36mInfo\033[0m]     %{endif}"
	                       "%{if-warning}\033[33mWarning\033[0m]  %{endif}"
	                       "%{if-critical}\033[31mCritical\033[0m] %{endif}"
	                       "%{if-fatal}\033[35mFatal\033[0m]    %{endif}"
	                       "%1%{if-category}%{category}: %{endif}"
	                       "%{message}").arg(filePrefix));
#endif

	QCoreApplication app(argc, argv, flags);
	if (!preStartService())
		return EXIT_FAILURE;

	// create lock
	qCDebug(logBackend) << "Creating service lock";
	QLockFile lock{service()->runtimeDir().absoluteFilePath(Q_T("qstandard.lock"))};
	lock.setStaleLockTime(std::numeric_limits<int>::max());  // disable stale locks
	if (!lock.tryLock(5000)) {
		qCCritical(logBackend) << "Failed to create service lock in"
		                       << service()->runtimeDir().absolutePath()
		                       << "with error code:" << lock.error();
		if (lock.error() == QLockFile::LockFailedError) {
			qint64 pid = 0;
			QString hostname, appname;
			if (lock.getLockInfo(&pid, &hostname, &appname)) {
				qCCritical(logBackend).noquote() << "Service already running as:"
				                                 << "\n\tPID:" << pid
				                                 << "\n\tHostname:" << hostname
				                                 << "\n\tAppname:" << appname;
			} else
				qCCritical(logBackend) << "Unable to determine current lock owner";
		}
		return EXIT_FAILURE;
	}

	// ensure unlocking always happens
	connect(qApp, &QCoreApplication::aboutToQuit, this, [&] { lock.unlock(); });
	connect(service(), QOverload<bool>::of(&Service::started),
	        this, &StandardServiceBackend::onStarted);
	connect(service(), QOverload<bool>::of(&Service::paused),
	        this, &StandardServiceBackend::onPaused);

#ifdef Q_OS_WIN
	for (const auto signal : {CTRL_C_EVENT, CTRL_BREAK_EVENT}) {
#else
	for (const auto signal : {SIGINT, SIGTERM, SIGQUIT, SIGHUP, SIGTSTP, SIGCONT, SIGUSR1, SIGUSR2}) {
#endif
		registerForSignal(signal);
	}

	// start the event loop
	qCDebug(logBackend) << "Starting service";
	QMetaObject::invokeMethod(this, "processServiceCommand", Qt::QueuedConnection,
	                          Q_ARG(QtService::ServiceBackend::ServiceCommand, ServiceCommand::Start));
	return app.exec();
}

void StandardServiceBackend::quitService()
{
	connect(service(), &Service::stopped, qApp, &QCoreApplication::exit);
	processServiceCommand(ServiceCommand::Stop);
}

void StandardServiceBackend::reloadService()
{
	processServiceCommand(ServiceCommand::Reload);
}

void StandardServiceBackend::signalTriggered(int signal)
{
	qCDebug(logBackend) << "Handling signal" << signal;
	switch(signal) {
#ifdef Q_OS_WIN
	case CTRL_C_EVENT:
	case CTRL_BREAK_EVENT:
		quitService();
		break;
#else
	case SIGINT:
	case SIGTERM:
	case SIGQUIT:
		quitService();
		break;
	case SIGHUP:
		reloadService();
		break;
	case SIGTSTP:
		processServiceCommand(ServiceCommand::Pause);
		break;
	case SIGCONT:
		processServiceCommand(ServiceCommand::Resume);
		break;
	case SIGUSR1:
		processServiceCallback("SIGUSR1");
		break;
	case SIGUSR2:
		processServiceCallback("SIGUSR2");
		break;
#endif
	default:
		ServiceBackend::signalTriggered(signal);
	}
}

void StandardServiceBackend::onStarted(bool success)
{
	if (!success)
		qApp->exit(EXIT_FAILURE);
}

void StandardServiceBackend::onPaused(bool success [[maybe_unused]])
{
#ifdef Q_OS_UNIX
	if (success)
		kill(getpid(), SIGSTOP);  // now actually stop
#endif
}
