import QtQuick 2.2
import Sailfish.Silica 1.0
//import QtQml.Models 2.1
import "../settings.js" as Settings

Dialog {
    id: sortingDialog
    //allowedOrientations: Orientation.Portrait

    /*
    property int setectedItem

    onAccepted: {
        var newOrder = []
        for (var i=0;i<visualModel.count;i++) {
            //console.log("listModel.userOrder: ",visualModel.items.get(i).model.userOrder)
            newOrder.push(visualModel.items.get(i).model.userOrder)
        }
        //console.log("listModel.userOrder: ",newOrder)
        listsModel.setUserOrder(newOrder)
    }

    DialogHeader {
        id: sortingHeader
        title: qsTr("Drag names of lists")
    }

    SilicaListView {
        id: sortingList
        anchors.top: sortingHeader.bottom
        width: parent.width
        height: parent.height - sortingHeader.height
        clip: true

        displaced: Transition {
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
        }

        model: DelegateModel {
            id: visualModel
            model: listsModel

            delegate: Item {
                id: delegateItem

                property int visualIndex: DelegateModel.itemsIndex

                width: ListView.view.width
                height: Theme.itemSizeSmall

                MouseArea {
                    id: delegateRoot
                    width: parent.width/3
                    height: Theme.itemSizeSmall
                    drag.target: data
                }

                DropArea {
                    anchors.fill: parent

                    onEntered: visualModel.items.move(drag.source.visualIndex, delegateItem.visualIndex)
                }

                Item {
                    id: data
                    width: parent.width
                    height: Theme.itemSizeSmall

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }

                    Drag.active: delegateRoot.drag.active
                    Drag.source: delegateItem
                    Drag.hotSpot.x: Theme.itemSizeSmall/2
                    Drag.hotSpot.y: Theme.itemSizeSmall/2

                    states: [
                        State {
                            when: data.Drag.active
                            ParentChange {
                                target: data
                                parent: sortingList
                            }

                            AnchorChanges {
                                target: data
                                anchors.verticalCenter: undefined
                            }
                            PropertyChanges {
                                target: colorIndicator
                                width: parent.width * 0.5
                            }
                        }
                    ]

                    Item { // background element with diagonal gradient
                        anchors.fill: parent
                        clip: true

                        Rectangle {
                            rotation: 9
                            width: sortingList.width*2
                            height: data.height
                            x: -sortingList.width

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0) }
                                GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        visible: favorite==1
                        color: Theme.rgba(Theme.highlightColor, 0.15)
                    }

                    Row { // delegate date
                        id: row
                        width: parent.width
                        height: parent.height

                        Item {
                            height: parent.height
                            width: Theme.horizontalPageMargin
                        }

                        Item {
                            id: colorArea
                            height: parent.height
                            width: Theme.paddingLarge

                            Rectangle {
                                id: colorIndicator
                                anchors.verticalCenter: parent.verticalCenter
                                //anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.4
                                height: parent.height * 0.8
                                radius: Math.round(Theme.paddingSmall/3)
                                color: listColor ? listColor : ""
                            }
                        }

                        Column {
                            id: column
                            width: parent.width - colorArea.width - counts.width - 2*Theme.horizontalPageMargin
                            anchors.verticalCenter: parent.verticalCenter

                            Label {
                                id: text2
                                width: parent.width
                                text: listName
                                truncationMode: TruncationMode.Fade
                            }

                            Label {
                                id: curDate
                                width: parent.width
                                text: listDate
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                            }
                        }

                        Label {
                            id: counts
                            width: parent.width/5
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                            text: listCount ? (listDone + "/" + listCount) : "0/0"
                            color: Theme.secondaryColor
                        }
                    }
                }
            }
        }
    }
    VerticalScrollDecorator {}

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            //busyIndicator.running = false;
            if (_navigation === PageNavigation.Back) {
                mainWindow.sortingOpened = false;
            }
        }
    }
    */
}
