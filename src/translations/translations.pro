TEMPLATE = aux

QDEP_LUPDATE_INPUTS += $$PWD/../service
QDEP_LUPDATE_INPUTS += $$PWD/../plugins
QDEP_LUPDATE_INPUTS += $$PWD/../imports
QDEP_LUPDATE_INPUTS += $$PWD/../java

TRANSLATIONS += \
	qtservice_de.ts \
	qtservice_template.ts

CONFIG += lrelease
QM_FILES_INSTALL_PATH = $$[QT_INSTALL_TRANSLATIONS]

include(../../../QConsole/qconsole.pri)
include(../../../QCtrlSignals/qctrlsignals.pri)

# replace template qm by ts
QM_FILES -= $$__qdep_lrelease_real_dir/qtservice_template.qm
QM_FILES += qtservice_template.ts

HEADERS =
SOURCES =
GENERATED_SOURCES =
OBJECTIVE_SOURCES =
RESOURCES =
