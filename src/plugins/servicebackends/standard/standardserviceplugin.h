#ifndef STANDARDSERVICEPLUGIN_H
#define STANDARDSERVICEPLUGIN_H

#include <QtService/ServicePlugin>

class StandardServicePlugin : public QObject, public QtService::ServicePlugin
{
	Q_OBJECT
	Q_PLUGIN_METADATA(IID QtService_ServicePlugin_Iid FILE "standard.json")
	Q_INTERFACES(QtService::ServicePlugin)

public:
	StandardServicePlugin(QObject *parent = nullptr);

	QString currentServiceId(const QString &backend) const override;
	QString findServiceId(const QString &backend, const QString &serviceName, const QString &domain) const override;
	QtService::ServiceBackend *createServiceBackend(const QString &backend, QtService::Service *service) override;
	QtService::ServiceControl *createServiceControl(const QString &backend, QString &&serviceId, QObject *parent) override;

	template<typename ServiceLike>
	static QString lockFilePath(const ServiceLike &s) {
		// use backend() below to serve the debug_and_release tests' concurrent execution
		return s.runtimeDir().absoluteFilePath(s.backend() + Q_T(".lock"));
	}
};

#endif // STANDARDSERVICEPLUGIN_H
