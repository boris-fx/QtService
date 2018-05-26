#ifndef WINDOWSSERVICEBACKEND_H
#define WINDOWSSERVICEBACKEND_H

#include <QtCore/QMutex>
#include <QtCore/QWaitCondition>
#include <QtCore/QThread>
#include <QtCore/QPointer>
#include <QtCore/QAbstractNativeEventFilter>

#include <QtService/ServiceBackend>

#include <QtCore/qt_windows.h>

class WindowsServiceBackend : public QtService::ServiceBackend
{
	Q_OBJECT

public:
	explicit WindowsServiceBackend(QObject *parent = nullptr);

	int runService(QtService::Service *service, int &argc, char **argv, int flags) override;
	void quitService() override;
	void reloadService() override;

private:
	class SvcControlThread : public QThread
	{
	public:
		SvcControlThread(WindowsServiceBackend *backend);
	protected:
		void run() override;

	private:
		WindowsServiceBackend *_backend;
	};

	class SvcEventFilter : public QAbstractNativeEventFilter
	{
	public:
		bool nativeEventFilter(const QByteArray &eventType, void *message, long *result);
	};

	static QPointer<WindowsServiceBackend> _backendInstance;

	QtService::Service *_service;

	QMutex _svcLock;
	QWaitCondition _startCondition;

	SERVICE_STATUS _status;
	SERVICE_STATUS_HANDLE _statusHandle = nullptr;

	//temporary stuff
	wchar_t *_svcName = const_cast<wchar_t*>(L"QtService");
	QByteArrayList _svcArgs;

	void setStatus(DWORD status);

	static void WINAPI serviceMain(DWORD dwArgc, wchar_t** lpszArgv);
	static void WINAPI handler(DWORD dwOpcode);

	static void winsvcMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);
};

#endif // WINDOWSSERVICEBACKEND_H
