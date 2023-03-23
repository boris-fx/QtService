TARGET = QtService

QT = core network core-private
android: QT += androidextras

include(../../../QConsole/qconsole.pri)
include(../../../QCtrlSignals/qctrlsignals.pri)

HEADERS += \
	qtservice_global.h \
	service.h \
	service_p.h \
	serviceplugin.h \
	qtservice_helpertypes.h \
	servicebackend.h \
	servicebackend_p.h \
	servicecontrol.h \
	servicecontrol_p.h \
	terminal.h \
	terminal_p.h \
	terminalserver_p.h \
	terminalclient_p.h

SOURCES += \
	service.cpp \
	servicebackend.cpp \
	servicecontrol.cpp \
	terminal.cpp \
	terminalserver.cpp \
	terminalclient.cpp \
	serviceplugin.cpp

MODULE_PLUGIN_TYPES = servicebackends
load(qt_module)

win32 {
	QMAKE_TARGET_PRODUCT = "QtService"
	QMAKE_TARGET_COMPANY = "Skycoder42"
	QMAKE_TARGET_COPYRIGHT = "Felix Barz"
} else: macos {
	QMAKE_TARGET_BUNDLE_PREFIX = "de.skycoder42."

	CONFIG(debug, debug|release) {  # need this for plugins' linkage
		!isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK += &&
		QMAKE_POST_LINK += \
			( cd \"$$shadowed($$dirname(_QMAKE_CONF_))/lib/QtService.framework\" && \
				( test -e QtService || ln -s QtService_debug QtService ) ; cd - ) 
	}
}
