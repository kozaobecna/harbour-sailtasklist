import QtQuick 2.2
import Sailfish.Silica 1.0
import "../settings.js" as Settings

Dialog {
    id: filtersPage

    property bool showCompleted: true
    property bool showUncompleted: true
    property int selectBar: 1

    acceptDestination: listsPageForFiltering

    Connections {
        target: mainWindow
        onSyncComplete: {
            connectionStatus.text = qsTr("Connected as") + " " + ioInterface.getUserName();
            connectionStatus.visible = true;
            pullDownMenu.busy = false;
        }
    }

    function selectChanged(number) {
        selectBar = number;
        if (number===1) {
            rect1.color = Theme.rgba(Theme.highlightColor, 0);
            rect2.color = Theme.rgba(Theme.highlightColor, 0.25);
            rect3.color = Theme.rgba(Theme.highlightColor, 0.25);
            mainWindow.showCompleted = true;
            mainWindow.showUncompleted = true;
        } else if (number===2) {
            rect1.color = Theme.rgba(Theme.highlightColor, 0.25);
            rect2.color = Theme.rgba(Theme.highlightColor, 0);
            rect3.color = Theme.rgba(Theme.highlightColor, 0.25);
            mainWindow.showCompleted = true;
            mainWindow.showUncompleted = false;
        } else if (number===3) {
            rect1.color = Theme.rgba(Theme.highlightColor, 0.25);
            rect2.color = Theme.rgba(Theme.highlightColor, 0.25);
            rect3.color = Theme.rgba(Theme.highlightColor, 0);
            mainWindow.showCompleted = false;
            mainWindow.showUncompleted = true;
        }
        tasksModel.fillFilteredTaskModel(mainWindow.showCompleted, mainWindow.showUncompleted, mainWindow.filterSortingOrder)
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu
            busy: ioInterface.getConnectionStatus() || ioInterface.getUpdatingStatus() ? true : false

            MenuItem {
                text: mainWindow.filterSortingOrder==0 ? qsTr("Oldest first") : qsTr("Newest first")
                onClicked: {
                    mainWindow.filterSortingOrder==1 ? mainWindow.filterSortingOrder=0 : mainWindow.filterSortingOrder=1
                    tasksModel.fillFilteredTaskModel(mainWindow.showCompleted, mainWindow.showUncompleted, mainWindow.filterSortingOrder)
                }
            }
            MenuLabel {
                id: connectionStatus
                visible: Settings.getLoginStatus() ? true : false
            }
        }

        Column {
            id: statisticBar
            width: parent.width

            Item {
                width: parent.width
                height: Theme.itemSizeSmall

                Rectangle {
                    anchors.fill: parent
                    color: Theme.rgba(Theme.highlightColor, 0.25)
                }

                Label {
                    anchors.fill: parent
                    text: qsTr("Statistic")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.highlightColor
                }
            }

            Row {
                width: parent.width
                height: Theme.itemSizeSmall



                BackgroundItem {
                    width: parent.width/3
                    height: parent.height
                    highlightedColor: Theme.rgba(Theme.highlightColor, 0)
                    Rectangle {
                        id: rect1
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightColor, 0)
                        Label {
                            id: textAll
                            width: parent.width
                            height: 2*parent.height/3
                            text: tasksModel.doneCount+tasksModel.undoneCount
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Label {
                            anchors.top: textAll.bottom
                            width: parent.width
                            height: parent.height/3
                            text: qsTr("All")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    onClicked: {
                        if (selectBar!=1) {
                            selectChanged(1)
                        }
                    }
                }

                BackgroundItem {
                    width: parent.width/3
                    height: parent.height
                    highlightedColor: Theme.rgba(Theme.highlightColor, 0)
                    Rectangle {
                        id: rect2
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightColor, 0.25)
                        Label {
                            id: textCompleted
                            width: parent.width
                            height: 2*parent.height/3
                            text: tasksModel.doneCount
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Settings.getColoredNumbersInStatisic()==1 ? "#00ff00" : Theme.primaryColor
                        }
                        Label {
                            anchors.top: textCompleted.bottom
                            width: parent.width
                            height: parent.height/3
                            text: qsTr("Completed")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    onClicked: {
                        if (selectBar!=2) {
                            selectChanged(2)
                        }
                    }
                }

                BackgroundItem {
                    width: parent.width/3
                    height: parent.height
                    highlightedColor: Theme.rgba(Theme.highlightColor, 0)
                    Rectangle {
                        id: rect3
                        anchors.fill: parent
                        color: Theme.rgba(Theme.highlightColor, 0.25)
                        Label {
                            id: textUncompleted
                            width: parent.width
                            height: 2*parent.height/3
                            text: tasksModel.undoneCount
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Settings.getColoredNumbersInStatisic()==1 ? "#ff0000" : Theme.primaryColor
                        }
                        Label {
                            anchors.top: textUncompleted.bottom
                            width: parent.width
                            height: parent.height/3
                            text: qsTr("Unсompleted")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeTiny
                        }
                    }

                    onClicked: {
                        if (selectBar!=3) {
                            selectChanged(3)
                        }
                    }
                }
            }
        }

        SilicaListView {
            id: list
            anchors.top: statisticBar.bottom
            width: parent.width
            height: parent.height - statisticBar.height
            clip: true

            model: tasksModel

            delegate: ListItem {
                width: ListView.view.width
                height: Theme.itemSizeSmall

                Rectangle {
                    y: - height/2 + parent.height
                    visible: Settings.getHideSeparatorsInFilters()==0 && tasksModel.filterSeparator(index, mainWindow.showCompleted, mainWindow.showUncompleted, mainWindow.filterSortingOrder)
                    width: parent.width
                    height: 2
                    color: Theme.rgba(Theme.highlightColor, 0.25)
                }

                Column {
                    Label {
                        x: Theme.horizontalPageMargin
                        text: index+1 + ". " + taskName
                        font.strikeout: done
                        truncationMode: TruncationMode.Elide
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        text: qsTr("List: ") + listName
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.secondaryColor
                        truncationMode: TruncationMode.Elide
                    }
                }

                onClicked: {
                    tasksModel.updateStatusForFiltering(index, listName, listDate, taskName, !done, mainWindow.showCompleted, mainWindow.showUncompleted, mainWindow.filterSortingOrder)
                    listsModel.fillListModel()
                    mainWindow.needUpdate = true;
                }
            }
        }
        VerticalScrollDecorator {flickable: list}

        Component {
            id: listsPageForFiltering

            Page {
                id: selectListsPage

                Label {
                    id: listsFilterHeader
                    width: parent.width - Theme.horizontalPageMargin
                    height: Theme.itemSizeMedium
                    text: qsTr("Select the displayed lists")
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    truncationMode: TruncationMode.Fade
                }

                SilicaListView {
                    id: listsFilter
                    anchors.top: listsFilterHeader.bottom
                    width: parent.width
                    height: parent.height - listsFilterHeader.height
                    clip: true

                    model: listsModel

                    delegate: Item {
                        width: ListView.view.width
                        height: Theme.itemSizeSmall

                        TextSwitch {
                            width: parent.width
                            text: listName
                            checked: listFilter==1

                            onCheckedChanged: listsModel.setListFilter(checked, listName, listDate)
                        }
                    }
                }
                VerticalScrollDecorator {flickable: listsFilter}

                onStatusChanged: {
                    if (status === PageStatus.Deactivating) {
                        if (_navigation === PageNavigation.Back) {
                            selectChanged(1);
                            listsModel.fillListModel();
                        }
                    }
                }
            }
        }
    }

    onStatusChanged: {
        if (status===PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                mainWindow.filtersOpened = false;
                //selectChanged(1);
            }
        } else if (status===PageStatus.Activating) {
            if (ioInterface.getConnectionStatus()) {
                connectionStatus.text = qsTr("Connecting...")
            } else if (ioInterface.getUpdatingStatus()) {
                connectionStatus.text = qsTr("Synchronization...")
            } else {
                if (ioInterface.getConnectedStatus()) {
                    connectionStatus.text = qsTr("Connected as") + " " + ioInterface.getUserName();
                } else {
                    connectionStatus.text = qsTr("Disconnected");
                }
            }

            tasksModelCover.clear()
            var i;
            if (Settings.getHideDoneTasksCover()) {
                for (i=0; i<Math.min(tasksModel.count-tasksModel.doneCount,5); ++i) {
                    tasksModelCover.append(tasksModel.get(i))
                }
            } else {
                for (i=0; i<Math.min(tasksModel.count,5); ++i) {
                    tasksModelCover.append(tasksModel.get(i))
                }
            }
        }
    }
}
