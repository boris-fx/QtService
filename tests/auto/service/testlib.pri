TEMPLATE = app

QT = core service testlib

CONFIG   += console
CONFIG   -= app_bundle

DEFINES += SRCDIR=\\\"$$_PRO_FILE_PWD_/\\\"

win32:!win32-g++:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../TestBaseLib/release/ -ltestbase
else:win32:!win32-g++:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../TestBaseLib/debug/ -ltestbase
else: LIBS += -L$$OUT_PWD/../TestBaseLib/ -ltestbase

INCLUDEPATH += $$PWD/TestBaseLib
DEPENDPATH += $$PWD/TestBaseLib

win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../TestBaseLib/release/testbase.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../TestBaseLib/debug/testbase.lib
else: PRE_TARGETDEPS += $$OUT_PWD/../TestBaseLib/libtestbase.a

# Docs at https://doc.qt.io/qt-5/qmake-variable-reference.html say:
# "When relative paths are specified, qmake will mangle them into a form understood by the
#  dynamic linker to be relative to the location of the referring executable or library."
macos: QMAKE_RPATHDIR = ../../../../lib  # to find QtService.framework not installed into Qt

include(../testrun.pri)
