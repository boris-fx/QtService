TEMPLATE = app

QT = core service

CONFIG += console
CONFIG -= app_bundle

TARGET = testservice

HEADERS += \
	testservice.h

SOURCES += \
	main.cpp \
	testservice.cpp

runtarget.target = run-tests
!compat_test {
	win32: runtarget.depends += $(DESTDIR_TARGET)
	else: runtarget.depends += $(TARGET)
}
QMAKE_EXTRA_TARGETS += runtarget

macos {
	# Docs at https://doc.qt.io/qt-5/qmake-variable-reference.html say:
	# "When relative paths are specified, qmake will mangle them into a form understood by the
	#  dynamic linker to be relative to the location of the referring executable or library."
	QMAKE_RPATHDIR = ../../../../lib  # to find QtService.framework not installed into Qt

	plugins_dir = "$$shadowed($$dirname(_QMAKE_CONF_))/plugins"  # used in the below template
	QMAKE_SUBSTITUTES *= "$$_PRO_FILE_PWD_/qt.conf.in"

	CONFIG(debug, debug|release) {  # need this for the plug-ins to be discovered by their factory
		# Notes:
		# 1. Xcode still ships with the ancient GNU make 3.81 which is the last version without .ONESHELL support, alas.
		# 2. Not using a 'for' loop below due to escaping nightmare (need two '$$LITERAL_DOLLAR's to get one '$' in sh).
		c  = 'cd "$$plugins_dir/servicebackends"'
		c += 'test -e libqstandard.dylib || ln -s libqstandard_debug.dylib libqstandard.dylib'
		c += 'test -e libqlaunchd.dylib  || ln -s libqlaunchd_debug.dylib  libqlaunchd.dylib '
		c += 'cd -'
		runtarget.commands = $$join(c, ;\\$$escape_expand(\\n\\t))
	}
}
