# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailtasklist

CONFIG += sailfishapp

SOURCES += \
    src/harbour-sailtasklist.cpp

DISTFILES += qml/harbour-sailtasklist.qml \
    harbour-sailtasklist.desktop \
    qml/TaskList.qml \
    qml/pages/CloudAuthorisationPage.qml \
    qml/pages/Filters.qml \
    qml/pages/ListsPage.qml \
    qml/pages/ManualSortingPage.qml \
    qml/pages/Settings.qml \
    qml/pages/TasksPage.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-sailtasklist.changes.in \
    rpm/harbour-sailtasklist.changes.run.in \
    rpm/harbour-sailtasklist.spec \
    translations/*.ts \
    translations/harbour-sailtasklist-cs.ts

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += sailfishapp_i18n


TRANSLATIONS += translations/harbour-sailtasklist-cs.ts
