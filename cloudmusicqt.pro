TEMPLATE = app
TARGET = cloudmusicqt

VERSION = 0.9.2
DEFINES += VER=\\\"$$VERSION\\\"

QT += network webkit sql

CONFIG += mobility
MOBILITY += multimedia systeminfo

HEADERS += \
    src/qmlapi.h \
    src/networkaccessmanagerfactory.h \
    src/singletonbase.h \
    src/userconfig.h \
    src/musicfetcher.h \
    src/blurreditem.h \
    src/musiccollector.h \
    src/musicdownloader.h \
    src/musicdownloaddatabase.h \
    src/musicdownloadmodel.h

SOURCES += src/main.cpp \
    src/qmlapi.cpp \
    src/networkaccessmanagerfactory.cpp \
    src/userconfig.cpp \
    src/musicfetcher.cpp \
    src/blurreditem.cpp \
    src/musiccollector.cpp \
    src/musicdownloader.cpp \
    src/musicdownloaddatabase.cpp \
    src/musicdownloadmodel.cpp

include(qjson/qjson.pri)
DEFINES += QJSON_MAKEDLL

TRANSLATIONS += i18n/cloudmusicqt_zh.ts

folder_symbian3.source = qml/cloudmusicqt
folder_symbian3.target = qml

folder_meego.source = qml/harmattan
folder_meego.target = qml

folder_js.source = qml/js
folder_js.target = qml

simulator {
    DEPLOYMENTFOLDERS = folder_symbian3 folder_js folder_meego
}

symbian {
    DEPLOYMENTFOLDERS = folder_symbian3 folder_js

    CONFIG += qt-components localize_deployment

    TARGET.UID3 = 0x2006DFF5

    TARGET.CAPABILITY += \
        NetworkServices \
        ReadUserData \
        WriteUserData \
        ReadDeviceData \
        WriteDeviceData \
        SwEvent

    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

    LIBS += -lavkon -leikcore -lgslauncher

    vendorinfo = "%{\"Yeatse\"}" ":\"Yeatse\""
    my_deployment.pkg_prerules += vendorinfo
    DEPLOYMENT += my_deployment

    # Symbian have a different syntax
    DEFINES -= VER=\\\"$$VERSION\\\"
    DEFINES += VER=\"$$VERSION\"

    MMP_RULES += "EPOCPROCESSPRIORITY windowserver"
}

contains(MEEGO_EDITION, harmattan) {
    message(harmattan build)

    QT += dbus
    CONFIG += meegotouch
    CONFIG += qdeclarative-boostable

    include(notifications/notifications.pri)

    DEPLOYMENTFOLDERS = folder_meego folder_js

    iconsvg.files += $${TARGET}_meego.svg
    iconsvg.path = /usr/share/themes/base/meegotouch/$${TARGET}
    gameclassify.files += qtc_packaging/debian_harmattan/$${TARGET}.conf
    gameclassify.path = /usr/share/policy/etc/syspart.conf.d

    HEADERS += src/cloudmusicif.h

    SOURCES += src/cloudmusicif.cpp

    INSTALLS += iconsvg gameclassify
}

# Please do not modify the following two lines. Required for deployment.
include(selectfilesdialog/selectfilesdialog.pri)
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog
