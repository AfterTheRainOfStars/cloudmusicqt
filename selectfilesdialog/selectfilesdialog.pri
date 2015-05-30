INCLUDEPATH += $$PWD
HEADERS += \
    $$PWD/selectfilesdialog.h

SOURCES += \
    $$PWD/selectfilesdialog.cpp

symbian{
    message(Symbian build)

    #CONFIG += mobility
    #MOBILITY += systeminfo

    RESOURCES += \
        $$PWD/sfd_symbian.qrc
    OTHER_FILES += \
        $$PWD/symbian.qml
}

simulator{
    message(Simulator build)
    RESOURCES += \
        $$PWD/sfd_symbian.qrc

    OTHER_FILES += \
        $$PWD/symbian.qml \
        $$PWD/meego.qml
}

contains(MEEGO_EDITION, harmattan){
    message(Harmattan build)
    DEFINES += HARMATTAN_BOOSTER

    RESOURCES += \
        $$PWD/sfd_meego.qrc

    OTHER_FILES += \
        $$PWD/meego.qml
}

RESOURCES += \
    $$PWD/sfd_icons.qrc
