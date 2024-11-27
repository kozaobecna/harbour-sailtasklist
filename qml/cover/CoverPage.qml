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

CoverBackground {
    id: coverPage

    property int selectItem: 0
    property var curListName
    property var curTaskName
    property var curDone
    property var curColor
    property var curDate
    property int selectItemCover: 0
    property int firstCoverElement: 0

    CoverPlaceholder {
        text: {
            if (mainWindow.settingsOpened) {
                qsTr("Lists\n\nSettings menu")
            } else if (mainWindow.copyOpened || mainWindow.sortingOpened) {
                qsTr("List not selected")
            } else if (!coverListView.count) {
                qsTr("List is empty")
            } else {
                qsTr("List not selected")
            }
        }
        visible: (pageStack.depth>2 || mainWindow.settingsOpened || mainWindow.copyOpened || mainWindow.sortingOpened || !coverListView.count) ? true : false
    }

    SilicaFlickable {
        id: list
        anchors.fill: parent

        Row {
            id: titleRow
            x: Theme.paddingLarge
            y: Theme.paddingMedium
            width: parent.width
            visible: !(mainWindow.settingsOpened)
            spacing: Theme.paddingSmall

            BackgroundItem {
                id: titleColor
                height: head.height
                width: head.height/2
                visible: (pageStack.depth===2 && !mainWindow.filtersOpened) ? true : false

                Rectangle {
                    id: colorIndicator2
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.4
                    height: parent.height * 0.6
                    radius: Math.round(Theme.paddingSmall/3)
                    color: (pageStack.depth===2) ? tasksModel.curColor : ""
                }
            }

            Label {
                id: head
                width: parent.width - Theme.paddingLarge - Theme.paddingMedium - titleColor.width
                text: {
                    if (pageStack.depth===1) {
                        qsTr("Lists")
                    } else if (!mainWindow.settingsOpened && !mainWindow.copyOpened && !mainWindow.sortingOpened && pageStack.depth===2) {
                        if (mainWindow.filtersOpened) {
                            qsTr("Filters menu")
                        } else {
                            //coverPage.curListName
                            tasksModel.curListName
                        }
                    } else {
                        ""
                    }
                }
                horizontalAlignment: Text.AlignLeft
                //font.bold: true
                truncationMode: TruncationMode.Fade
            }
        }

        SilicaListView {
            id: coverListView
            anchors.top: titleRow.bottom
            width: parent.width
            height: parent.height - titleRow.height - 110
            visible: !(mainWindow.settingsOpened)

            model: {
                if (pageStack.depth===1) {
                    listsModelCover
                } else if (pageStack.depth===2) {
                    if (mainWindow.settingsOpened || mainWindow.copyOpened || mainWindow.sortingOpened) {
                        0
                    } else {
                        tasksModelCover
                    }
                } else {
                    0
                }
            }

            delegate: ListItem {
                id: delegate
                width: ListView.view.width
                height: width/5

                Row {
                    x: pageStack.depth===1 ? Theme.paddingMedium : Theme.paddingLarge
                    width: parent.width
                    height: parent.height

                    BackgroundItem {
                        id: colorPickerButton
                        height: parent.height/2
                        width: parent.height/3
                        visible: pageStack.depth===1 ? true : false

                        Rectangle {
                            id: colorIndicator
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.2
                            height: parent.height * 0.8
                            radius: Math.round(Theme.paddingSmall/3)
                            color: pageStack.depth===1 ? listColor : ""
                            visible: (index==coverPage.selectItemCover) ? true : false
                        }
                    }
                    Label {
                        id: text
                        width: parent.width - Theme.paddingLarge - 2*Theme.paddingMedium
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            if (pageStack.depth===1) {
                                listName
                            } else if (!mainWindow.settingsOpened && pageStack.depth===2) {
                                if (mainWindow.filtersOpened) {
                                    (index+1+coverPage.firstCoverElement) + ". " + taskName
                                } else {
                                    if (Settings.getSortingTasks()===1) {
                                        (tasksModel.count-index-coverPage.firstCoverElement) + ". " + taskName
                                    } else {
                                        (index+1+coverPage.firstCoverElement) + ". " + taskName
                                    }
                                }
                            } else {
                                ""
                            }
                        }
                        color: (index==coverPage.selectItemCover) ? Theme.highlightColor : Theme.secondaryColor
                        font.pixelSize: (index==coverPage.selectItemCover) ? Theme.fontSizeMedium : Theme.fontSizeSmall
                        font.strikeout: (!mainWindow.settingsOpened && pageStack.depth===2) ? done : false
                        truncationMode: TruncationMode.Fade
                    }
                }
            }
        }

        Component.onCompleted: {
            coverPage.curListName = listsModel.getName(coverPage.selectItem);
            coverPage.curColor = listsModel.getColor(coverPage.selectItem);
            coverPage.curDate = listsModel.getDate(coverPage.selectItem);
        }

        CoverActionList {
            id: coverAction
            enabled: {
                if (pageStack.depth>2 || mainWindow.settingsOpened || mainWindow.copyOpened) {
                    false
                } else {
                    true
                }
            }

            /* This action implements navigation in lists: down and back, when tasks list is empty. */
            CoverAction {
                iconSource: (tasksModel.doneCount===tasksModel.count && pageStack.depth===2) ? "image://theme/icon-cover-previous-song" : "../resources/harbour-cover-down.png"
                onTriggered: {
                    if (tasksModel.doneCount===tasksModel.count && pageStack.depth===2) {
                        mainWindow.pageStack.navigateBack();
                        coverPage.selectItem = 0;
                        coverPage.selectItemCover = 0;
                        coverPage.firstCoverElement = 0;
                    } else {
                        var i;
                        if (pageStack.depth===1) {
                            coverPage.selectItem++;
                            if (coverPage.selectItem>=listsModel.count) {
                                coverPage.selectItem = 0;
                            }
                            if (listsModel.count>5) {
                                if (coverPage.selectItem<3) {
                                    coverPage.selectItemCover = coverPage.selectItem
                                    if (coverPage.selectItemCover==0) {
                                        coverPage.firstCoverElement = 0;
                                    }
                                    listsModelCover.clear();
                                    for (i=0; i<5; ++i) {
                                        listsModelCover.append(listsModel.get(i));
                                    }
                                } else if ((listsModel.count-coverPage.firstCoverElement)<=5) {
                                    coverPage.selectItemCover++;
                                    listsModelCover.clear();
                                    for (i=0; i<5; ++i) {
                                        listsModelCover.append(listsModel.get(i+coverPage.firstCoverElement));
                                    }
                                } else {
                                    coverPage.firstCoverElement++;
                                    //console.log("coverPage.firstCoverElement: ", coverPage.firstCoverElement)
                                    listsModelCover.clear();
                                    for (i=0; i<5; ++i) {
                                        listsModelCover.append(listsModel.get(i+coverPage.firstCoverElement));
                                    }
                                }
                            } else {
                                coverPage.selectItemCover = coverPage.selectItem;
                            }
                        } else if (pageStack.depth===2) {
                            coverPage.selectItem++;
                            var coverCount;
                            if (Settings.getHideDoneTasksCover()) {
                                coverCount = tasksModel.count-tasksModel.doneCount;
                            } else {
                                coverCount = tasksModel.count;
                            }
                            if (Settings.getBackNavigateAtCover()) {
                                if (coverPage.selectItem==coverCount-1) {
                                    iconSource = "image://theme/icon-cover-previous-song"
                                }
                            }

                            if (coverPage.selectItem>=coverCount) {
                                coverPage.selectItem = 0;

                                if (Settings.getBackNavigateAtCover()) {
                                    iconSource = "../resources/harbour-cover-down.png"
                                    mainWindow.pageStack.navigateBack();
                                    coverPage.selectItemCover = 0;
                                    coverPage.firstCoverElement = 0;
                                }
                            }
                            if (tasksModel.count>5) {
                                var modelCount = Math.min(tasksModel.count-tasksModel.doneCount,5);
                                if (coverPage.selectItem<3) {
                                    coverPage.selectItemCover = coverPage.selectItem;
                                    if (coverPage.selectItemCover==0) {
                                        coverPage.firstCoverElement = 0;
                                    }
                                    tasksModelCover.clear()
                                    for (i=0; i<modelCount; ++i) {
                                        tasksModelCover.append(tasksModel.get(i));
                                    }
                                } else if ((coverCount-coverPage.firstCoverElement)<=5) {
                                    coverPage.selectItemCover++;
                                    tasksModelCover.clear();
                                    for (i=0; i<modelCount; ++i) {
                                        tasksModelCover.append(tasksModel.get(i+coverPage.firstCoverElement));
                                    }
                                } else {
                                    coverPage.firstCoverElement++
                                    //console.log("coverPage.firstCoverElement: ", coverPage.firstCoverElement)
                                    tasksModelCover.clear()
                                    for (i=0; i<modelCount; ++i) {
                                        tasksModelCover.append(tasksModel.get(i+coverPage.firstCoverElement));
                                    }
                                }
                            } else {
                                coverPage.selectItemCover = coverPage.selectItem;
                            }
                        }
                    }
                }
            }

            /* This action implements entering into the list and done/undone tasks in the list. */
            CoverAction {
                iconSource: pageStack.depth===1 ? "image://theme/icon-cover-next-song" : "../resources/harbour-cover-done.png"
                onTriggered: {
                    if (pageStack.depth===1) {
                        coverPage.curListName = listsModel.getName(coverPage.selectItem);
                        coverPage.curColor = listsModel.getColor(coverPage.selectItem);
                        coverPage.curDate = listsModel.getDate(coverPage.selectItem);
                        tasksModel.fillTaskModel(coverPage.curListName,coverPage.curDate,coverPage.curColor);
                        mainWindow.pageStack.push(Qt.resolvedUrl("../pages/TasksPage.qml"), {currentIndex: coverPage.selectItem} );
                        coverPage.selectItem = 0;
                        coverPage.selectItemCover = 0;
                        coverPage.firstCoverElement = 0;
                    } else if (pageStack.depth===2) {
                        //coverPage.curTaskName = tasksModel.getName(coverPage.selectItem);
                        coverPage.curTaskName = tasksModel.getTaskName(coverPage.selectItem);
                        coverPage.curDone = tasksModel.getDone(coverPage.selectItem);
                        if (mainWindow.filtersOpened) {
                            coverPage.curListName = tasksModel.getListName(coverPage.selectItem);
                            coverPage.curDate = tasksModel.getDate(coverPage.selectItem);
                        }
                        if (coverPage.selectItem==(coverListView.count-1) && coverPage.selectItem!=0) {
                            coverPage.selectItem = coverPage.selectItem-1;
                            coverPage.selectItemCover = coverPage.selectItem;
                        }
                        if (mainWindow.filtersOpened) {
                            tasksModel.updateStatusForFiltering(coverPage.selectItem, coverPage.curListName, coverPage.curDate, coverPage.curTaskName, !coverPage.curDone, mainWindow.showCompleted, mainWindow.showUncompleted, mainWindow.filterSortingOrder) //!!!
                        } else {
                            tasksModel.updateStatus(coverPage.selectItem, tasksModel.curListName, tasksModel.curDate, tasksModel.curColor, coverPage.curTaskName, !coverPage.curDone);
                        }
                        listsModel.fillListModel();
                        tasksModelCover.clear();
                        if (Settings.getHideDoneTasksCover()) {
                            for (var i=0; i<Math.min(tasksModel.count-tasksModel.doneCount,5); ++i) {
                                tasksModelCover.append(tasksModel.get(i+coverPage.firstCoverElement));
                            }
                        } else {
                            for (var i=0; i<Math.min(tasksModel.count,5); ++i) {
                                tasksModelCover.append(tasksModel.get(i+coverPage.firstCoverElement));
                            }
                        }
                    }
                }
            }
        }
    }

    onStatusChanged: {
        //console.log("cover opened")
        if (mainWindow.settingsOpened) {
            listsModelCover.clear();
            tasksModelCover.clear();
        } else {
            coverPage.selectItem = 0;
            coverPage.selectItemCover = 0;
            coverPage.firstCoverElement = 0;

            listsModelCover.clear()
            for (var i=0; i<Math.min(listsModel.count,5); ++i) {
                listsModelCover.append(listsModel.get(i));
            }

            tasksModelCover.clear()
            if (Settings.getHideDoneTasksCover()) {
                //console.log("doneCount: ",tasksModel.count)
                //console.log("doneCount: ",tasksModel.doneCount)
                for (var i=0; i<Math.min(tasksModel.count-tasksModel.doneCount,5); ++i) {
                    tasksModelCover.append(tasksModel.get(i));
                }
            } else {
                for (var i=0; i<Math.min(tasksModel.count,5); ++i) {
                    tasksModelCover.append(tasksModel.get(i));
                }
            }
        }
    }
}

