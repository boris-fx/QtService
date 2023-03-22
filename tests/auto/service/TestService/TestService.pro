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

# Docs at https://doc.qt.io/qt-5/qmake-variable-reference.html say:
# "When relative paths are specified, qmake will mangle them into a form understood by the
#  dynamic linker to be relative to the location of the referring executable or library."
macos: QMAKE_RPATHDIR = ../../../../lib  # to find QtService.framework not installed into Qt
