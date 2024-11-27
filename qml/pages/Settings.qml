import QtQuick 2.2
import Sailfish.Silica 1.0
import "../settings.js" as Settings

Page {
    id: settingsPage

    function resetDb() {
            remorse.execute(qsTr("Database will reset"), function() { listsModel.resetDb() } )
    }

    function resetSettings() {
        remorse.execute(
            qsTr("Reset settings"),
            function() {
                Settings.resetSettings();
                listsTimeout.value = Settings.getTimeoutLists();
                tasksTimeout.value = Settings.getTimeoutTasks();
                dateHiding.checked = Settings.getHideDate();
                doneHidingCover.checked = Settings.getHideDoneTasksCover();
                coloredNumbersInStatisic.checked = Settings.getColoredNumbersInStatisic();
                hideSeparatorsInFilters.checked = Settings.getHideSeparatorsInFilters();
                backNavigateOnCover.checked = Settings.getBackNavigateAtCover();
                addListsFromMenu.checked = Settings.getAddListsFromMenu();
                sortingOrderLists.currentIndex = Settings.getTimeoutLists();
                sortingOrderTasks.currentIndex = Settings.getTimeoutTasks();
                //mainWindow.pageStack.navigateBack()
            }
        )
    }
    RemorsePopup { id: remorse }

    Connections {
        target: ioInterface
        onSendUserName: {
            connectionStatus.text = qsTr("Connected as") + " " + userName;
            connectionStatus.visible = true;
            loginButton.text = qsTr("Log out");
            //console.log("acc recieved")
            ioInterface.setConnectionStatus(false);
            loginButton.enabled = true;
            pullDownMenu.busy = false;
            mainWindow.stopSyncing();
        }
        onSendAppKeys: {
            Settings.setDboxToken(token);
            Settings.setDboxSecret(tokenSecret);
            console.log("keys recieved")
        }
        onConnectionError: {
            connectionStatus.text = qsTr("Disconnected")
            connectionStatus.visible = true;
            ioInterface.setConnectionStatus(false);
            pullDownMenu.busy = false;
        }
    }

    Connections {
        target: mainWindow
        onStartSyncing: {
            settingsPage.backNavigation = false
            busyIndicator.running = true
            syncLabel.visible = true
            syncLabelWait.visible = true
        }
        onStartDownload: {
            syncLabel.text = qsTr("Downloading...")
        }
        onStartUpload: {
            syncLabel.text = qsTr("Uploading...")
        }
        onStopSyncing: {
            settingsPage.backNavigation = true
            busyIndicator.running = false
            syncLabel.visible = false
            syncLabelWait.visible = false
        }
    }

    Label {
        id: syncLabel
        color: Theme.highlightColor
        text: qsTr("Connecting...")
        width: parent.width
        height: Theme.itemSizeMedium
        anchors.bottom: busyIndicator.top
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: false
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        size: BusyIndicatorSize.Large
    }

    Label {
        id: syncLabelWait
        color: Theme.highlightColor
        text: qsTr("Please, wait")
        width: parent.width
        height: Theme.itemSizeMedium
        anchors.top: busyIndicator.bottom
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: false
    }

    SilicaFlickable {
        id: set
        anchors.fill: parent
        visible: !busyIndicator.running
        contentHeight:  isLandscape ? header.height + listsTimeout.height + dateHiding.height + coloredNumbersInStatisic.height + backNavigateOnCover.height +
                                      sortingOrderLists.height + cloudStorage.height + aboutAndThanks.height + Theme.paddingLarge : header.height +
                                      listsTimeout.height + tasksTimeout.height + dateHiding.height + doneHidingCover.height + coloredNumbersInStatisic.height +
                                      hideSeparatorsInFilters.height + backNavigateOnCover.height + addListsFromMenu.height + sortingOrderLists.height +
                                      sortingOrderTasks.height + cloudStorage.height + aboutAndThanks.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        PullDownMenu {
            id: pullDownMenu
            busy: ioInterface.getConnectionStatus() || ioInterface.getUpdatingStatus() ? true : false

            MenuItem {
                text: qsTr("Reset database")
                onClicked: settingsPage.resetDb()
            }

            MenuItem {
                text: qsTr("Default settings")
                onClicked: settingsPage.resetSettings()
            }
            MenuLabel {
                id: connectionStatus
                //visible: Settings.getLoginStatus() ? true : false
            }
        }

        PageHeader {
            id: header
            title: qsTr("Settings")
        }

        Slider {
            id: listsTimeout
            width: isLandscape ? parent.width/2 : parent.width
            anchors.top: header.bottom
            value: Settings.getTimeoutLists()
            minimumValue: 0
            maximumValue: 5
            stepSize: 1
            handleVisible: true
            valueText : value
            label: qsTr("Timeout for deleting lists (sec.)")

            onValueChanged: {
                Settings.updateTimeoutLists(value)
                listsModel.fillListModel()
            }
        }

        Slider {
            id: tasksTimeout
            width: isLandscape ? parent.width/2 : parent.width
            anchors {
                top: isLandscape ? header.bottom : listsTimeout.bottom
                left: isLandscape ? listsTimeout.right : parent.left
            }
            value: Settings.getTimeoutTasks()
            minimumValue: 0
            maximumValue: 5
            stepSize: 1
            handleVisible: true
            valueText : value
            label: qsTr("Timeout for deleting tasks (sec.)")

            onValueChanged: Settings.updateTimeoutTasks(value)
        }


        TextSwitch {
            id: dateHiding
            width: isLandscape ? parent.width/2 : parent.width
            height: isLandscape ? doneHidingCover.height : Theme.itemSizeSmall
            anchors.top: isLandscape ? listsTimeout.bottom : tasksTimeout.bottom
            text: qsTr("Hide date")
            checked: Settings.getHideDate()

            onCheckedChanged: {
                Settings.updateHideDate(checked)
                listsModel.fillListModel()
            }
        }

        TextSwitch {
            id: doneHidingCover
            width: isLandscape ? parent.width/2 : parent.width
            anchors {
                top: isLandscape ? tasksTimeout.bottom : dateHiding.bottom
                left: isLandscape ? dateHiding.right : parent.left
            }
            text: qsTr("Hide done tasks on cover")
            checked: Settings.getHideDoneTasksCover()

            onCheckedChanged: Settings.updateHideDoneTasksCover(checked)
        }

        TextSwitch {
            id: coloredNumbersInStatisic
            width: isLandscape ? parent.width/2 : parent.width
            anchors.top: isLandscape ? dateHiding.bottom : doneHidingCover.bottom
            text: qsTr("Colored numbers in statistic")
            checked: Settings.getColoredNumbersInStatisic()

            onCheckedChanged: Settings.setColoredNumbersInStatisic(checked)
        }

        TextSwitch {
            id: hideSeparatorsInFilters
            width: isLandscape ? parent.width/2 : parent.width
            anchors {
                top: isLandscape ? doneHidingCover.bottom : coloredNumbersInStatisic.bottom
                left: isLandscape ? coloredNumbersInStatisic.right : parent.left
            }
            text: qsTr("Hide separators in filters")
            checked: Settings.getHideSeparatorsInFilters()

            onCheckedChanged: Settings.setHideSeparatorsInFilters(checked)
        }

        TextSwitch {
            id: backNavigateOnCover
            width: isLandscape ? parent.width/2 : parent.width
            anchors.top: isLandscape ? coloredNumbersInStatisic.bottom : hideSeparatorsInFilters.bottom
            text: qsTr("Return after scroll list on cover")
            checked: Settings.getBackNavigateAtCover()

            onCheckedChanged: Settings.setBackNavigateAtCover(checked)
        }

        TextSwitch {
            id: addListsFromMenu
            width: isLandscape ? parent.width/2 : parent.width
            height: isLandscape ? backNavigateOnCover.height : Theme.itemSizeSmall
            anchors {
                top: isLandscape ? hideSeparatorsInFilters.bottom : backNavigateOnCover.bottom
                left: isLandscape ? sortingOrderLists.right : parent.left
            }
            text: qsTr("Add lists from menu")
            checked: Settings.getAddListsFromMenu()

            onCheckedChanged: {
                Settings.setAddListsFromMenu(checked)
                mainWindow.needRefresh = true
            }
        }

        ComboBox {
            id: sortingOrderLists
            width: isLandscape ? parent.width/2 : parent.width
            anchors.top: isLandscape ? backNavigateOnCover.bottom : addListsFromMenu.bottom
            label: qsTr("Sorting order in lists:")
            currentIndex: Settings.getSortingLists()

            menu: ContextMenu {
                MenuItem { text: qsTr("Oldest first") }
                MenuItem { text: qsTr("Newest first") }
                MenuItem { text: qsTr("In ABC order") }
                //MenuItem { text: qsTr("Manual sorting") }
            }

            onCurrentIndexChanged: {
                Settings.updateSortingLists(currentIndex)
                listsModel.fillListModel()
            }
        }

        ComboBox {
            id: sortingOrderTasks
            width: isLandscape ? parent.width/2 : parent.width
            anchors {
                top: isLandscape ? addListsFromMenu.bottom : sortingOrderLists.bottom
                left: isLandscape ? sortingOrderLists.right : parent.left
            }
            label: qsTr("Sorting order in tasks:")
            currentIndex: Settings.getSortingTasks()

            menu: ContextMenu {
                MenuItem { text: qsTr("Oldest first") }
                MenuItem { text: qsTr("Newest first") }
                MenuItem { text: qsTr("In ABC order") }
            }

            onCurrentIndexChanged: Settings.updateSortingTasks(currentIndex)
        }

        Column {
            id: cloudStorage
            width: parent.width
            anchors.top: sortingOrderTasks.bottom
            spacing: Theme.paddingLarge

            Label {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Cloud storage")
            }



            Row {
                //spacing: Theme.paddingLarge
                //anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: Theme.itemSizeSmall

                Label {
                    color: Theme.highlightColor
                    text: "Dropbox"
                    width: parent.width/2
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    width: parent.width/2
                    height: parent.height
                    Button {
                        id: loginButton
                        text: Settings.getLoginStatus() ? qsTr("Log out") : qsTr("Log in")
                        anchors.horizontalCenter:  parent.horizontalCenter
                        enabled: !(ioInterface.getConnectionStatus() || ioInterface.getUpdatingStatus())
                        onClicked: {
                            if (ioInterface.getConnectedStatus()) {
                                Settings.clearDropboxAccountInfo();
                                ioInterface.leaveDropbox();
                                text = qsTr("Log in");
                                connectionStatus.visible = false
                                //connectButton.enabled = false;
                            } else {
                                busyIndicator.running = true;
                                mainWindow.pageStack.push(Qt.resolvedUrl("CloudAuthorisationPage.qml"), {}, PageStackAction.Immediate);
                            }
                        }
                    }
                }

                /*Button {
                    id: connectButton
                    text: qsTr("Reconnect")
                    enabled: Settings.getLoginStatus()
                    onClicked: {
                        pullDownMenu.busy = true
                        ioInterface.setConnectionStatus(true);
                        ioInterface.setAppKeys(Settings.getDboxToken(),Settings.getDboxSecret())
                        ioInterface.getAccountInfo();
                    }
                }*/
            }

            /*TextSwitch {
                id: autoconnect2Dbox
                width: parent.width
                text: qsTr("Autoconnect")
                visible: ioInterface.getConnectedStatus()
                checked: Settings.getAutoconnect2Dbox()

                onCheckedChanged: Settings.setAutoconnect2Dbox(checked)
            }*/
        }

        Column {
            id: aboutAndThanks
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.top: cloudStorage.bottom //sortingOrderTasks.bottom //

            Label {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("About")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("The application allows you to create and store lists in a convenient way. On the cover, you can navigate through the generated lists and complete the tasks.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Main features:\n- Intuitive interface\n- Cover navigation\n- Intellectual tasks adding\n- Copy/paste tasks between lists\n- Dropbox synchronization\n- Sorting modes\n- Favorite lists\n- Statistic and filters")
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                Label {
                    width: parent.width
                    wrapMode: TextEdit.WordWrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Application can use Dropbox (NOT WORKING) for sharing your lists with all your phones. Just log in and wait until the application has completed the initial setup. For update your lists in Dropbox storage you need return at 'Lists page'. If you close your application before it, your dropbox storage will update with next launch of application.")
                }

                Label {
                    width: parent.width
                    wrapMode: TextEdit.WordWrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("When you delete your list from your device it will not permanent delete from storage and just untracked because current Dropbox API do not support delete function. You can clean your folder in storage manually if you need.")
                }

                Label {
                    width: parent.width
                    wrapMode: TextEdit.WordWrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("If you lost your network connection, application will try reconnect every 5 minutes. Just wait or restart your application.")
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Available languages: ") + "English, Czech."
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("If you find a bug or want help us with translations application on other languages, please, submit issue on the github.")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Version: ") + "1.3.2"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Sources: ") + "https://github.com/kozaobecna/harbour-sailtasklist"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Author: ") + "Dmitriy Lukyanov"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Built for aarch64: ") + "Koza Obecná"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: TextEdit.WordWrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("If you like our application, you can leave comments, click 'Like' or flattring our app. Your feedback and support very important for us. Thank you!")
            }

            Label {
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Thanks")
            }

            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "Svetlana Zorina"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for patience and help in testing")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "Koza Obecná"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for Czech translation")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
/*
            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "Åke Engelbrektson"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for Swedish translation")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "Moth"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for German translation")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "lunatix"
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for French translation")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Row {
                x: Theme.horizontalPageMargin
                Label {
                    text: "Jani N."
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                Label {
                    text: qsTr(" - for Finnish translation")
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
            */
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            busyIndicator.running = false;
            if (_navigation === PageNavigation.Back) {
                mainWindow.settingsOpened = false;
                //console.log("mainWindow.settingsOpened2: ", mainWindow.settingsOpened)
            }
        } else if (status === PageStatus.Activating) {
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
        }
    }
}
