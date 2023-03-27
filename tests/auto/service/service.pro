TEMPLATE = subdirs

SUBDIRS += \
	TestBaseLib \
	TestService \
	TestStandardService \
	TestTerminalService

unix:!android:!ios:packagesExist(libsystemd):system(systemctl --version): SUBDIRS += TestSystemdService
win32: SUBDIRS += TestWindowsService
macos: SUBDIRS += TestLaunchdService

TestStandardService.depends += TestBaseLib TestService
TestTerminalService.depends += TestBaseLib TestService
TestSystemdService.depends  += TestBaseLib TestService
TestWindowsService.depends  += TestBaseLib TestService
TestLaunchdService.depends  += TestBaseLib TestService

prepareRecursiveTarget(run-tests)
QMAKE_EXTRA_TARGETS += run-tests
