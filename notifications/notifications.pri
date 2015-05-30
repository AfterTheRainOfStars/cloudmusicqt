nicons.files = \
    $$PWD/icon-m-service-$${TARGET}.png \
    $$PWD/icon-m-low-power-mode-$${TARGET}.png \
    $$PWD/icon-s-status-notifier-$${TARGET}.png \
    $$PWD/icon-s-status-$${TARGET}.png
nicons.path = /usr/share/themes/blanco/meegotouch/icons

eventtype.files = $$PWD/$${TARGET}.conf
eventtype.path = /usr/share/meegotouch/notifications/eventtypes

INSTALLS += nicons eventtype
