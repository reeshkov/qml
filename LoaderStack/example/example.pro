QT += quick
QT += qml

CONFIG += c++11

SOURCES += \
        main.cpp

DISTFILES += \
    main.qml \
    test-server/errorComponent.qml \
    test-server/loadedComponent.qml \
    test-server/qmldir \
    test-server/server.py \
    test-server/tempoComponent.qml

#DEFINES *= USE_QQMLENGINE # uncomment to use QQuickView:
SRCPATH = $$_PRO_FILE_PWD_/main.qml
DEFINES *= SRCPATH=\\\"$$SRCPATH\\\"
