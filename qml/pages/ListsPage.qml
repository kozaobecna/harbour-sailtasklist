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
    id: listsPage

    property int textHeight: 80
    property var curList
    property int setectedItem
    property var listBuf: []
    property var listForCopy: []
    property int countBuf

    function addingNewList(newListName) {
        var data = listsModel.addList(newListName);
        tasksModel.fillTaskModel(newListName,data.date,data.color);
        listsModel.fillListModel();
        mainWindow.pageStack.push(Qt.resolvedUrl("TasksPage.qml"), {currentIndex: list.count, currentId: data.id} );
        mainWindow.needUpdate = true;
        mainWindow.newFile = true;
    }
/*
    Connections {
        target: ioInterface
        onSendUserName: {
            //connectionStatus.text = qsTr("Connected as") + " " + userName;
            connectionStatus.visible = true;
            ioInterface.setConnectionStatus(false);
            checkDropbox();
        }
        onConnectionError: {
            connectionStatus.text = qsTr("Disconnected")
            connectionStatus.visible = true;
            ioInterface.setConnectionStatus(false);
            pullDownMenu.busy = false;
        }
        onStartDelete: {
            console.log("delete started")
            var ret = checkDropbox();
            if (!ret) {
                deleteFromDropbox(mainWindow.idForDelete);
            }
        }
        onStartUpdate: {
            console.log("update started")
            checkDropbox();
        }
    }
*/
    Connections {
        target: mainWindow

        onNeedRefreshChanged: {
            if (mainWindow.needRefresh) {
                if (Settings.getAddListsFromMenu()) {
                    newListMenu.visible = true
                    newList.visible = false
                    list.height = listsPage.height
                    list.anchors.top = list.parent.top
                } else {
                    newListMenu.visible = false
                    newList.visible = true
                    list.height = listsPage.height - newList.height - 18
                    list.anchors.top = newList.bottom
                }
                mainWindow.needRefresh = false
            }
        }
    }


    Component {
        id: remorsecomponent
        RemorseItem {
            wrapMode: Text.Wrap
        }
    }

    DockedPanel {
        id: addListPanel

        width: parent.width
        height: Theme.itemSizeSmall + 40

        dock: Dock.Top

        TextField {
            id: newListPanel
            y: Theme.paddingLarge
            width: parent.width
            label: qsTr("Press 'Enter' to create new list")
            placeholderText: qsTr("Add new list")
            focus: false
            EnterKey.iconSource: "image://theme/icon-m-enter-next"

            EnterKey.onClicked: {
                addingNewList(text);
                text = "";
                focus = false;
                addListPanel.hide();
                list.anchors.top = list.parent.top;
            }

            onFocusChanged: {
                if (!focus) {
                    addListPanel.hide();
                    list.anchors.top = list.parent.top;
                }
            }
        }
    }



    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu
            // removing DropBox// busy: ioInterface.getConnectionStatus() || ioInterface.getUpdatingStatus() ? true : false

            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    mainWindow.settingsOpened = true
                    mainWindow.pageStack.push(Qt.resolvedUrl("Settings.qml"), {} )
                }
            }

            /*MenuItem {
                id: manualSortingButton
                text: qsTr("Sort lists")
                onClicked: {
                    mainWindow.sortingOpened = true
                    listsModel.initiateUserOrder()
                    mainWindow.pageStack.push(Qt.resolvedUrl("ManualSortingPage.qml"), {} )
                }
            }*/

            MenuItem {
                text: qsTr("Statistic and filters")
                onClicked: {
                    mainWindow.filtersOpened = true
                    tasksModel.fillFilteredTaskModel(mainWindow.showCompleted, mainWindow.showUncompleted,mainWindow.filterSortingOrder)
                    mainWindow.pageStack.push(Qt.resolvedUrl("Filters.qml"), {} )}
            }

            MenuItem {
                id: newListMenu
                text: qsTr("Add new list")
                visible: Settings.getAddListsFromMenu()
                onClicked: {
                    list.anchors.top = undefined
                    list.y = addListPanel.height
                    addListPanel.show()
                    newListPanel.focus = true
                    newListPanel.forceActiveFocus()
                }
            }


            MenuLabel {
                id: connectionStatus
            }
        }

        TextField {
            id: newList
            y: Theme.paddingLarge
            width: parent.width
            label: qsTr("Press 'Enter' to create new list")
            placeholderText: qsTr("Add new list")
            focus: false
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            visible: !Settings.getAddListsFromMenu()

            EnterKey.onClicked: {
                addingNewList(text);
                text = "";
            }
        }

        SilicaGridView {
            id: list
            anchors.top: { if (!Settings.getAddListsFromMenu()) newList.bottom }
            width: parent.width
            height: Settings.getAddListsFromMenu() ? parent.height : parent.height - newList.height - 20
            model: listsModel
            clip: true
            cellWidth: isLandscape ? parent.width / 2 : parent.width
            cellHeight: Theme.itemSizeSmall

            property int columnCount: Math.floor(parent.width / cellWidth)
            property Item contextMenu
            property int minOffsetIndex: listsPage.setectedItem - (listsPage.setectedItem % columnCount) + columnCount
            property int yOffset: contextMenu ? contextMenu.height : 0

            ViewPlaceholder {
                text: qsTr("You have not lists =(")
                enabled: list.count == 0
            }

            delegate: Item {
                id: myListItem

                width: list.cellWidth
                height: menuOpen ? list.contextMenu.height + delegate.height : delegate.height

                property bool menuOpen: list.contextMenu != null && list.contextMenu.parent === myListItem

                function editingList() {
                    editList.focus = true
                    listsPage.setectedItem = index
                    editList.selectAll()
                    editList.forceActiveFocus()
                }

                function removeList() {
                    var remorse = remorsecomponent.createObject(myListItem)
                    var string;
                    switch (Qt.locale().name.substring(0,2)) {
                        case "de":   // German
                            string = "'" + listName + "' " + qsTr("Deleting");
                            break;
                        default:
                            string = qsTr("Deleting") + " '" + listName + "'";
                    }
                    remorse.execute(delegate, string,
                                    function() {

// !!! quick fix for List deletion - removing DropBox

                                   /*     if (ioInterface.getConnectedStatus()) {
                                            mainWindow.idForDelete = id;
                                            ioInterface.readyForDelete();
                                        }
                                    */
                                        listsModel.deleteList(index,listName,listDate);
                                    },
                                    Settings.getTimeoutLists()*1000)
                }

                function openCopyDialog() {
                    mainWindow.copyOpened = true;
                    tasksModel.fillTaskModel(text2.text,curDate.text,colorIndicator.color)
                    listsPage.listBuf = [];
                    listsPage.listBuf.push(text2.text);
                    listsPage.listBuf.push(curDate.text);
                    for (var i=0;i<tasksModel.tasksCount-1;i++) {
                        listsPage.listBuf.push(1);
                    }
                    mainWindow.pageStack.push(copyPage)
                }

                function copyTasks() {
                    listsModel.copyTasks(listsPage.listForCopy, text2.text, curDate.text, colorIndicator.color);
                    listsModel.fillListModel();
                    if (ioInterface.getConnectedStatus()) {
                        ioInterface.readyForUpdate();
                    }
                }

                function selectFavText() {
                    if (favorite==1) {
                        return qsTr("Remove from favorite")
                    } else {
                        return qsTr("Add to favorite")
                    }
                }

                function changeFavorite() {
                    listsModel.changeFavorite(text2.text, curDate.text);
                    listsModel.fillListModel();
                    if (ioInterface.getConnectedStatus()) {
                        ioInterface.readyForUpdate();
                    }
                }

                BackgroundItem {
                    id: delegate
                    y: index >= list.minOffsetIndex ? list.yOffset : 0
                    width: parent.width
                    ListView.onRemove: animateRemoval()

                    Item { // background element with diagonal gradient
                        anchors.fill: parent
                        clip: true

                        Rectangle {
                            rotation: 9
                            width: list.width*2
                            height: delegate.height
                            x: -list.width

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
                                text: listName ? listName : ""
                                truncationMode: TruncationMode.Fade
                                visible: {
                                    if(editList.focus===true) {
                                        index!=listsPage.setectedItem ? true : false
                                    } else {
                                        true
                                    }
                                }
                            }

                            TextField {
                                x: - Theme.horizontalPageMargin
                                id: editList
                                width: parent.width
                                labelVisible: false
                                text: listName
                                visible: (index==listsPage.setectedItem && focus==true) ? true : false
                                EnterKey.onClicked: {
                                    listsModel.renameList(listName, text, listDate);
                                    ioInterface.readyForUpdate();
                                }
                                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                            }

                            Label {
                                id: curDate
                                width: parent.width
                                text: listDate
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                visible: {
                                    if (Settings.getHideDate()) {
                                        false
                                    } else {
                                        editList.focus!==true ? true : false
                                    }
                                }
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

                    onPressAndHold: {
                        listsPage.setectedItem = index
                        if (!list.contextMenu) {
                            list.contextMenu = contextMenuComponent.createObject(list)
                        }
                        list.contextMenu.open(myListItem)
                    }

                    onClicked: {
                        editList.focus = false
                        newListPanel.focus = false
                        tasksModel.fillTaskModel(text2.text,curDate.text,colorIndicator.color)
                        mainWindow.pageStack.push(Qt.resolvedUrl("TasksPage.qml"), {currentIndex: index, currentId: id} )
                    }
                }
            }
            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: contMenu

                    MenuItem {
                        id: favMenu
                        text: contMenu.parent.selectFavText()
                        onClicked: contMenu.parent.changeFavorite()
                    }

                    MenuItem {
                        text: qsTr("Edit list name")
                        onClicked: contMenu.parent.editingList()
                    }

                    MenuItem {
                        text: qsTr("Copy tasks")
                        onClicked: contMenu.parent.openCopyDialog()
                    }

                    MenuItem {
                        text: qsTr("Paste tasks")
                        visible: listsPage.listForCopy.length>0 ? true : false
                        onClicked: contMenu.parent.copyTasks()
                    }

                    MenuItem {
                        text: qsTr("Delete list")
                        onClicked: contMenu.parent.removeList();
                    }
                }
            }
            Component {
                id: copyPage

                Dialog {
                    id: copyDialog

                    onAccepted: {
                        listsPage.listForCopy = listsPage.listBuf;
                        mainWindow.copyOpened = false;
                    }

                    DialogHeader {
                        id: copyHeader
                        title: qsTr("Select tasks for copy")
                    }

                    SilicaListView {
                        id: copyList
                        anchors.top: copyHeader.bottom
                        width: parent.width
                        height: parent.height - copyHeader.height
                        clip: true
                        //visible: true

                        model: tasksModel

                        delegate: ListItem {
                            width: ListView.view.width
                            height: Theme.itemSizeSmall

                            TextSwitch {
                                id:testtest
                                width: parent.width
                                text: taskName
                                checked: true

                                onCheckedChanged: checked ? listBuf[index+2]=1 : listBuf[index+2]=0
                            }
                        }
                    }
                    VerticalScrollDecorator {flickable: copyList}
                }
            }
            VerticalScrollDecorator {flickable: list}
        }
    }

    onStatusChanged: {
        if (status===PageStatus.Activating) {
            /*if (Settings.getSortingLists()===3) {
                manualSortingButton.visible = true
            } else {
                manualSortingButton.visible = false
            }*/
// removing DropBox
            /*
            if (Settings.getLoginStatus()) {
                connectionStatus.visible = true
            } else {
                connectionStatus.visible = false
            }

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
            newList.focus = false;

            listsModelCover.clear()
            for (var i=0; i<Math.min(listsModel.count,5); ++i) {
                listsModelCover.append(listsModel.get(i))
            }
        } else if (status===PageStatus.Active) {
            // Removing DropBox //
            /*if (mainWindow.needUpdate) {
                pullDownMenu.busy = true;
                ioInterface.setUpdatingStatus(true);

                if (ioInterface.getConnectedStatus()) {
                    checkDropbox();
                }

                ioInterface.setUpdatingStatus(false);
                pullDownMenu.busy = false;
                mainWindow.needUpdate = false;
            }*/
        }
    }

    Component.onCompleted: {
        checkDropboxAutoconnect();
    }


    function checkDropboxAutoconnect() {
        if (Settings.getLoginStatus() && Settings.getAutoconnect2Dbox()===1) {
            if (!ioInterface.getConnectedStatus()) {
                pullDownMenu.busy = true;
                connectionStatus.text = qsTr("Connecting...")
                ioInterface.setConnectionStatus(true);
                ioInterface.setAppKeys(Settings.getDboxToken(),Settings.getDboxSecret());
                ioInterface.getAccountInfo();
            }
        }
    }

    function checkDropbox() {
        connectionStatus.text = qsTr("Checking for updates...")
        ioInterface.setUpdatingStatus(true)
        var ret = ioInterface.checkDropboxFiles(Settings.getLastDboxFileHash(),listsModel.dbVersionForDbox);
        if (ret===1) {
            console.log("start download")
            connectionStatus.text = qsTr("Synchronization...")
            downloadFromDropbox();
        } else if (ret===2) {
            console.log("start upload")
            connectionStatus.text = qsTr("Synchronization...")
            mainWindow.startUpload();
            uploadToDropbox(true);
        } else if (ret===3) {
            console.log("error. your db is no actuial. please, update your app")
        } else if (ret===4) {
            console.log("db is busy. try again later")
        } else if (ret===5) {
            console.log("reinit dbox")
            mainWindow.startDownload();
            connectionStatus.text = qsTr("Synchronization...")
            downloadFromDropbox();
            mainWindow.startUpload();
            uploadToDropbox(true);
        } else {
            var status = Settings.getLocalDatabaseStatus();
            var ids = status.split(",")
            if (ids[0]==="actual") {
                console.log("updates no need")
            } else {
                console.log("need upload")
                connectionStatus.text = qsTr("Synchronization...")
                mainWindow.idForUpdate = ids;
                uploadToDropbox(false);
                mainWindow.idForUpdate = [];
                Settings.setLocalDatabaseStatus("actual");
            }
        }
        //Settings.setLocalDatabaseStatus("actual")
        ioInterface.setUpdatingStatus(false)
        pullDownMenu.busy = false;
        connectionStatus.text = qsTr("Connected as") + " " + ioInterface.getUserName();

        mainWindow.syncComplete();

        return ret;
    }

    function uploadToDropbox(allFiles) {
        console.log("uploadToDropbox: ",allFiles)
        var lists;
        var ret;
        if (allFiles) {
            lists = listsModel.createJSON();
            ret = ioInterface.uploadToDropbox(Settings.getLastDboxFileHash(),lists);
        } else {
            lists = listsModel.createJSON();
            ret = ioInterface.updateDropboxFile(lists,mainWindow.newFile);
        }

        if (ret) {
            Settings.setLastDboxFileHash(ioInterface.getLastRevisionHash());
            console.log("upload success")
            mainWindow.newFile = false;
            return true;
        } else {
            console.log("upload failed")
            return false;
        }
    }

    function downloadFromDropbox() {
        var newLists = ioInterface.downloadFromDropbox(Settings.getLastDboxFileHash())
        var len = Object.keys(newLists).length;

        console.log("downloaded lists: " + len)
        if (len===0) {
            console.log("download failed")
            return false;
        }

        if (newLists[0]!=="empty") {
            var ret = listsModel.importData(newLists);
            if (!ret) {
                return false;
            }
        }
        Settings.setLastDboxFileHash(ioInterface.getLastRevisionHash());
        console.log("download success")

        return true;
    }

    function deleteFromDropbox(id) {
        connectionStatus.text = qsTr("Synchronization...")
        ioInterface.setUpdatingStatus(true)
        pullDownMenu.busy = true;
        var ret = ioInterface.deleteDropboxFile(id, listsModel.dbVersionForDbox);

        if (ret) {
            Settings.setLastDboxFileHash(ioInterface.getLastRevisionHash());
            console.log("delete success")
        } else {
            console.log("delete failed")
        }
        ioInterface.setUpdatingStatus(false)
        pullDownMenu.busy = false;
        connectionStatus.text = qsTr("Connected as") + " " + ioInterface.getUserName();

        return ret;
    }
}


