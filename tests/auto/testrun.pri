debug_and_release:!ReleaseBuild:!DebugBuild {
	runtarget.target = run-tests
	runtarget.CONFIG = recursive
	runtarget.recurse_target = run-tests
	QMAKE_EXTRA_TARGETS += runtarget
} else {
	oneshell.target = .ONESHELL
	QMAKE_EXTRA_TARGETS += oneshell

	repo_root = $$shadowed($$dirname(_QMAKE_CONF_))
	LF_TAB    = $$escape_expand(\\n\\t)

	win32:!win32-g++ {
		CONFIG(debug, debug|release): outdir_helper = debug
		CONFIG(release, debug|release): outdir_helper = release
		runtarget.target = run-tests
		!compat_test: runtarget.depends += $(DESTDIR_TARGET)
		runtarget.commands += set PATH=$$shell_path($$repo_root/bin);$$shell_path($$[QT_INSTALL_BINS]);$(PATH)
		runtarget.commands += $${LF_TAB}set QT_PLUGIN_PATH=$$repo_root/plugins;$$[QT_INSTALL_PLUGINS];$(QT_PLUGIN_PATH)
		runtarget.commands += $${LF_TAB}set QML2_IMPORT_PATH=$$repo_root/qml;$$[QT_INSTALL_QML];$(QML2_IMPORT_PATH)
		!isEmpty(LOGGING_RULES): runtarget.commands += $${LF_TAB}set \"QT_LOGGING_RULES=$$LOGGING_RULES\"
		runtarget.commands += $${LF_TAB}if exist $${outdir_helper}\\fail del $${outdir_helper}\\fail
		runtarget.commands += $${LF_TAB}start /w call $(DESTDIR_TARGET) ^> $${outdir_helper}\\test.log ^|^| echo FAIL ^> $${outdir_helper}\\fail ^& exit 0
		runtarget.commands += $${LF_TAB}type $${outdir_helper}\\test.log
		runtarget.commands += $${LF_TAB}if exist $${outdir_helper}\\fail exit 42
		QMAKE_EXTRA_TARGETS += runtarget
	} else {
		win32-g++: QMAKE_DIRLIST_SEP = ";"
		runtarget.commands += export PATH=\"$$shell_path($$repo_root/bin):$$shell_path($$[QT_INSTALL_BINS]):$${LITERAL_DOLLAR}$${LITERAL_DOLLAR}PATH\"
		runtarget.commands += $${LF_TAB}export QT_PLUGIN_PATH=\"$$repo_root/plugins$${QMAKE_DIRLIST_SEP}$$[QT_INSTALL_PLUGINS]$${QMAKE_DIRLIST_SEP}$(QT_PLUGIN_PATH)\"
		runtarget.commands += $${LF_TAB}export QML2_IMPORT_PATH=\"$$repo_root/qml$${QMAKE_DIRLIST_SEP}$$[QT_INSTALL_QML]$${QMAKE_DIRLIST_SEP}$(QML2_IMPORT_PATH)\"
		!isEmpty(LOGGING_RULES): runtarget.commands += $${LF_TAB}export QT_LOGGING_RULES=\"$$LOGGING_RULES\"
		win32-g++: QMAKE_DIRLIST_SEP = ":"

		linux|win32-g++ {
			runtarget.commands += $${LF_TAB}export LD_LIBRARY_PATH=\"$$repo_root/lib$${QMAKE_DIRLIST_SEP}$$[QT_INSTALL_LIBS]$${QMAKE_DIRLIST_SEP}$(LD_LIBRARY_PATH)\"
			runtarget.commands += $${LF_TAB}export QT_QPA_PLATFORM=minimal
		} else:mac {
			runtarget.commands += $${LF_TAB}export DYLD_LIBRARY_PATH=\"$$repo_root/lib:$$[QT_INSTALL_LIBS]:$(DYLD_LIBRARY_PATH)\"
			runtarget.commands += $${LF_TAB}export DYLD_FRAMEWORK_PATH=\"$$repo_root/lib:$$[QT_INSTALL_LIBS]:$(DYLD_FRAMEWORK_PATH)\"
		}

		runtarget.target = run-tests
		win32-g++ {
			!compat_test: runtarget.depends += $(DESTDIR_TARGET)
			runtarget.commands += $${LF_TAB}./$(DESTDIR_TARGET)
		} else {
			!compat_test: runtarget.depends += $(TARGET)
			runtarget.commands += $${LF_TAB}./$(TARGET)
		}
		QMAKE_EXTRA_TARGETS += runtarget

		macos {
			plugins_dir = "$$repo_root/plugins"  # used in the below template
			QMAKE_SUBSTITUTES *= "$$_PRO_FILE_PWD_/qt.conf.in"
		}
	}
}
