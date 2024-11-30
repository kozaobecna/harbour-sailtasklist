/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../settings.js" as Settings

Page {
    id: tasksPage

    property alias currentIndex: tasksPage.index
    property alias currentId: tasksPage.id

    property int setectedItem
    property int index
    property string id

    Connections {
        target: mainWindow
        onSyncComplete: {
            connectionStatus.text = qsTr("Connected as") + " " + ioInterface.getUserName();
            connectionStatus.visible = true;
            pullDownMenu.busy = false;
        }
    }

    function deleteList() {
        var string;
        switch (Qt.locale().name.substring(0,2)) {
            case "de":   // German
                string = "'" + tasksModel.curListName + "' " + qsTr("Deleting");
                break;
            default:
                string = qsTr("Deleting") + " '" + tasksModel.curListName + "'";
        }

        remorse.execute(
            string, //qsTr("Deleting '")+tasksModel.curListName+"'",
            function() {
// quick fix for List Deletion
/*
                if (ioInterface.getConnectedStatus()) {
                    mainWindow.idForDelete = currentId;
                    ioInterface.readyForDelete();
                }
*/
                listsModel.deleteList(tasksPage.index,tasksModel.curListName,tasksModel.curDate);
                mainWindow.pageStack.navigateBack();
                mainWindow.needUpdate = false;
            },
            Settings.getTimeoutLists()*1000
        )
    }
    function clearingList() {
        var string;
        switch (Qt.locale().name.substring(0,2)) {
            case "de":   // German
                string = "'" + tasksModel.curListName + "' " + qsTr("Clearing");
                break;
            default:
                string = qsTr("Clearing") + " '" + tasksModel.curListName + "'";
        }

        remorse.execute(
            string,
            function() {
                tasksModel.clearList(title.text, curDate.text, colorIndicator.color);
                listsModel.fillListModel();
                mainWindow.needUpdate = true;
            },
            3000
        )
    }
    function deletingCompleted() {
        remorse.execute(
            qsTr("Delete completed"),
            function() {
                tasksModel.clearDoneTasks(title.text, curDate.text, colorIndicator.color);
                listsModel.fillListModel();
                mainWindow.needUpdate = true;
            },
            3000
        )
    }
    RemorsePopup { id: remorse }

    SilicaFlickable {
        anchors.fill: parent
        id: grid

        PullDownMenu {
            id: pullDownMenu
            // Removing DropBox // busy: ioInterface.getConnectionStatus() || ioInterface.getUpdatingStatus() ? true : false

            MenuItem {
                text: qsTr("Delete list")
                onClicked: deleteList()
            }

            MenuItem {
                text: qsTr("Clear list")
                onClicked: clearingList()
            }

            MenuItem {
                text: qsTr("Complete all tasks")
                onClicked: {
                    tasksModel.compliteAllTasks(title.text, curDate.text, colorIndicator.color);
                    listsModel.fillListModel();
                    mainWindow.needUpdate = true;
                }
            }

            MenuItem {
                text: qsTr("Delete completed")
                onClicked: deletingCompleted()
            }
            MenuLabel {
                id: connectionStatus
                visible: Settings.getLoginStatus() ? true : false
            }
        }

        Row {
            id: titleRow
            x: Theme.horizontalPageMargin
            width: parent.width
            height: Theme.itemSizeLarge

            TextField {
                id: addTaskStrLand
                width: parent.width / 2
                labelVisible: false
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: (list.count+1) + qsTr(". Add new task")
                focus: false
                visible: isLandscape

                EnterKey.onClicked: {
                    tasksModel.addTask(title.text,colorIndicator.color,text,curDate.text)
                    listsModel.fillListModel()
                    text = ""
                    mainWindow.needUpdate = true;
                }
            }

            BackgroundItem {
                width: isLandscape ? ((parent.width / 2) - colorPickerButton.width - Theme.horizontalPageMargin) : (parent.width - colorPickerButton.width - Theme.horizontalPageMargin)
                anchors.verticalCenter: parent.verticalCenter

                Column {
                    id: listHeader
                    width: parent.width

                    Label {
                        id: title
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.highlightColor
                        text: tasksModel.curListName
                        truncationMode: TruncationMode.Fade
                    }

                    Label {
                        id: curDate
                        width: parent.width
                        font.pixelSize: Theme.fontSizeExtraSmall
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.secondaryColor
                        text: tasksModel.curDate
                    }
                }

                TextField {
                    id: editListName
                    width: parent.width
                    label: tasksModel.curListName
                    anchors.verticalCenter: parent.verticalCenter
                    text: tasksModel.curListName
                    visible: focus ? true : false
                    color: Theme.highlightColor
                    focus: false

                    EnterKey.onClicked: {
                        //tasksModel.curListName = text;
                        listsModel.renameList(tasksModel.curListName, text, tasksModel.curDate);
                        tasksModel.fillTaskModel(text,tasksModel.curDate,tasksModel.curColor);
                        visible = false;
                        listHeader.visible = true;
                        mainWindow.needUpdate = true;
                    }

                    onFocusChanged: {
                        if (!focus) {
                            visible = false;
                            listHeader.visible = true;
                        }
                    }
                }

                onClicked: {
                    listHeader.visible = false;
                    editListName.visible = true;
                    editListName.focus = true;
                    editListName.forceActiveFocus()
                }
            }

            BackgroundItem {
                id: colorPickerButton
                width: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: colorIndicator
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.height * 0.8
                    height: parent.height * 0.8
                    radius: Math.round(Theme.paddingSmall/3)
                    color: tasksModel.curColor
                }

                onClicked: {
                    var page = pageStack.push("Sailfish.Silica.ColorPickerPage", { color: colorIndicator.color })
                    page.colorClicked.connect(function(color) {
                        colorIndicator.color = color;
                        tasksModel.updateColor(color, title.text, curDate.text);
                        listsModel.fillListModel();
                        pageStack.pop();
                        mainWindow.needUpdate = true;
                    })
                }
            }
        }

        TextField {
            id: addTaskStr
            width: parent.width
            anchors.top: titleRow.bottom
            labelVisible: false
            placeholderText: (list.count+1) + qsTr(". Add new task")
            focus: false
            visible: isPortrait

            EnterKey.onClicked: {
                tasksModel.addTask(title.text,colorIndicator.color,text,curDate.text)
                listsModel.fillListModel()
                text = ""
                //list.scrollToBottom()
                mainWindow.needUpdate = true;
            }
        }

        SilicaListView {
            id: list
            anchors.top: isLandscape ? titleRow.bottom : addTaskStr.bottom
            width: parent.width
            height: isLandscape ? (parent.height - titleRow.height) : (parent.height - addTaskStr.height - titleRow.height)
            model: tasksModel
            clip: true

            delegate: ListItem {
                id: delegate
                width: ListView.view.width
                menu: taskMenu

                function removeTask() {
                    var string;
                    switch (Qt.locale().name.substring(0,2)) {
                        case "de":   // German
                            string = "'" + taskName + "' " + qsTr("Deleting");
                            break;
                        default:
                            string = qsTr("Deleting") + " '" + taskName + "'";
                    }

                    remorseAction(
                        string, //qsTr("Deleting '")+taskName+"'",
                        function() {
                            tasksModel.deleteTask(index,title.text,curDate.text,taskName);
                            listsModel.fillListModel();
                            mainWindow.needUpdate = true;
                        },
                        Settings.getTimeoutTasks()*1000
                    )
                }

                Item {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: curLabel
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*x
                        text: (Settings.getSortingTasks()===1) ? ((tasksModel.count-index) + ". " + taskName) : ((index+1) + ". " + taskName)
                        anchors.verticalCenter: parent.verticalCenter
                        font.strikeout: done
                        wrapMode: TextEdit.WordWrap
                        truncationMode: TruncationMode.Elide
                        maximumLineCount: 2
                        visible: {
                            if(editTask.focus===true) {
                                index!=tasksPage.setectedItem ? true : false
                            } else {
                                true
                            }
                        }
                    }

                    TextField {
                        id: editTask
                        width: parent.width
                        label: (index+1) + ". " + taskName
                        anchors.verticalCenter: parent.verticalCenter
                        text: taskName
                        visible: (index==tasksPage.setectedItem && focus==true) ? true : false

                        EnterKey.onClicked: {
                            tasksModel.renameTask(taskName, text, tasksModel.curListName, tasksModel.curDate, tasksModel.curColor)
                            mainWindow.needUpdate = true;
                        }
                    }
                }

                Component {
                    id: taskMenu

                    ContextMenu {
                        MenuItem {
                            text: qsTr("Edit task name")
                            onClicked: {
                                editTask.focus = true
                                tasksPage.setectedItem = index
                                editTask.selectAll()
                                editTask.forceActiveFocus()
                            }
                        }

                        MenuItem {
                            text: qsTr("Delete task")
                            onClicked: removeTask()
                        }
                    }
                }

                onClicked: {
                    tasksModel.updateStatus(index, title.text, curDate.text, colorIndicator.color, taskName, !done)
                    listsModel.fillListModel()
                    mainWindow.needUpdate = true;
                }
            }
            VerticalScrollDecorator{}
        }
    }

    onStatusChanged: {
        if (status===PageStatus.Activating) {
            // Removing DropBox //
            /*
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
*/
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








