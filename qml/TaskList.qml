import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import "settings.js" as Settings

ListModel {
    id: listModel

    property int listsCount
    property int tasksCount
    property int doneCount
    property int undoneCount
    property var curListName
    property var curDate
    property var curColor
    property int dbVersion: 17
    property int dbVersionForDbox: 1

    function _rawOpenDb() {
        return LocalStorage.openDatabaseSync('TaskList', '', 'Task list', 10000);
    }

    /* Updating version needed for add new date in db.
       Executed only one time after run new version of application */
    function upgradeSchema(db) {
        if (db.version == '') {
            db.changeVersion('', '1', function (tx) {
                tx.executeSql("CREATE TABLE lists(listName TEXT, listColor TEXT, taskName TEXT, done BIT)", []);
            })
            db = _rawOpenDb()
        }
        if (db.version == '1') {
            db.changeVersion('1', '2', function (tx) {
                tx.executeSql("CREATE TABLE next_color_index (value INTEGER)")
                tx.executeSql("INSERT INTO next_color_index VALUES (0)")
            })
            db = _rawOpenDb()
        }
        if (db.version == '2') {
            db.changeVersion('2', '3', function (tx) {
                tx.executeSql("ALTER TABLE lists ADD listDate TEXT")
            })
            db = _rawOpenDb()
        }
        if (db.version == '3') {
            db.changeVersion('3', '4', function (tx) {
                tx.executeSql("CREATE TABLE settings (parameter TEXT, value INTEGER, defValue INTEGER)")
                tx.executeSql("INSERT INTO settings VALUES('timeoutLists',5,5)");
                tx.executeSql("INSERT INTO settings VALUES('timeoutTasks',5,5)");
                tx.executeSql("INSERT INTO settings VALUES('hideData',0,0)");
                tx.executeSql("INSERT INTO settings VALUES('hideDoneTasksCover',0,0)");
            })
            db = _rawOpenDb()
        }
        if (db.version == '4') {
            db.changeVersion('4', '5', function (tx) {
                tx.executeSql("ALTER TABLE lists ADD id TEXT")
                tx.executeSql("INSERT INTO settings VALUES('sortLists',0,0)");
                tx.executeSql("INSERT INTO settings VALUES('sortTasks',0,0)");
                tx.executeSql("INSERT INTO settings VALUES('settingOpened',0,0)"); // not used
            })
            db = _rawOpenDb()
        }
        if (db.version == '5') {
            db.changeVersion('5', '6', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('hideDate',0,0)");
            })
            db = _rawOpenDb()
        }
        if (db.version == '6') {
            db.changeVersion('6', '7', function (tx) {
                tx.executeSql("ALTER TABLE lists ADD listFilter TEXT");
                var rs = tx.executeSql("SELECT DISTINCT listFilter FROM lists WHERE done=2", []);
                if (rs.rows.length > 0) {
                    tx.executeSql("UPDATE lists SET listFilter=1");
                }
            })
            db = _rawOpenDb()
        }
        if (db.version == '7') {
            db.changeVersion('7', '8', function (tx) {
                tx.executeSql("ALTER TABLE lists ADD favorite INTEGER");
                var rs = tx.executeSql("SELECT DISTINCT favorite FROM lists WHERE done=2", []);
                if (rs.rows.length > 0) {
                    tx.executeSql("UPDATE lists SET favorite=0");
                }
            })
            db = _rawOpenDb()
        }
        if (db.version == '8') {
            db.changeVersion('8', '9', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('coloredNumbersInStatisic',0,0)");
                tx.executeSql("INSERT INTO settings VALUES('hideSeparatorsInFilters',0,0)");
            })
            db = _rawOpenDb()
        }
        if (db.version == '9') {
            db.changeVersion('9', '10', function (tx) {
                tx.executeSql("ALTER TABLE settings ADD stringValue TEXT")
                tx.executeSql("INSERT INTO settings VALUES('dboxToken',0,0,'empty')");
                tx.executeSql("INSERT INTO settings VALUES('dboxSecret',0,0,'empty')");
                tx.executeSql("INSERT INTO settings VALUES('autoconnect2Dbox',1,1,'')");
            })
            db = _rawOpenDb()
        }
        if (db.version == '10') {
            db.changeVersion('10', '11', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('lastDboxFileHash',0,0,'')");
            })
            db = _rawOpenDb()
        }
        if (db.version == '11') {
            db.changeVersion('11', '12', function (tx) {})
            db = _rawOpenDb()
        }
        if (db.version == '12') {
            db.changeVersion('12', '13', function (tx) {
                var rs = tx.executeSql("SELECT id FROM lists ORDER BY id DESC");
                if (rs.rows.length > 0) {
                    var item, item2
                    for (var i=0;i<rs.rows.length;i++) {
                        item = rs.rows.item(i).id;
                        item2 = rs.rows.item(i).id + "00";
                        tx.executeSql("UPDATE lists SET id=? WHERE id=?", [item2, item]);
                    }
                }
            })
            db = _rawOpenDb()
        }
        if (db.version == '13') {
            db.changeVersion('13', '14', function (tx) {
                tx.executeSql("ALTER TABLE lists ADD userOrder INTEGER");
                var rs = tx.executeSql("SELECT DISTINCT userOrder FROM lists WHERE done=2", []);
                if (rs.rows.length > 0) {
                    tx.executeSql("UPDATE lists SET userOrder=0");
                }
            })
            db = _rawOpenDb()
        }
        if (db.version == '14') {
            db.changeVersion('14', '15', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('localDatabaseStatus',0,0,'actual')");
            })
            db = _rawOpenDb()
        }
        if (db.version == '15') {
            db.changeVersion('15', '16', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('backNavigateAtCover',0,0,'')");
            })
            db = _rawOpenDb()
        }
        if (db.version == '16') {
            db.changeVersion('16', '17', function (tx) {
                tx.executeSql("INSERT INTO settings VALUES('addListsFromMenu',0,0,'')");
            })
            db = _rawOpenDb()
        }
    }

    function openDb() {
        var db = _rawOpenDb()
        if (parseInt(db.version) != dbVersion)
            upgradeSchema(db);
        return db;
    }

    function resetDb() {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("DELETE FROM lists", []);
                tx.executeSql("UPDATE next_color_index SET value=0");
                /*db.changeVersion('10', '', function (tx) {
                    tx.executeSql("DROP TABLE lists")
                    tx.executeSql("DROP TABLE settings")
                })*/
                listModel.clear();
                listsCount = 0;
            }
        )
    }

    function fillListModel() {
        var db = openDb()
        db.transaction(
            function(tx) {
                /*var rs1 = tx.executeSql("SELECT userOrder FROM lists WHERE done=2 ORDER BY userOrder ASC ,id DESC");
                var userOrder
                for (var i=0; i<rs1.rows.length; ++i) {
                    userOrder = rs1.rows.item(i).userOrder;
                    //if (!wrongId) {
                        console.log("id: ",userOrder);
                        //console.log("listName: ",rs1.rows.item(i).listName);
                        //console.log("taskName: ",rs1.rows.item(i).taskName);
                        //tx.executeSql("DELETE FROM lists WHERE id=?", [wrongId]);
                    //}
                }*/

                var rs
                var sort = Settings.getSortingLists();
                if (sort===1) {
                    rs = tx.executeSql("SELECT DISTINCT listName,listColor,listDate,listFilter,favorite,userOrder,id FROM lists WHERE done=2 ORDER BY favorite DESC, id DESC", []);
                } else if (sort===2) {
                    rs = tx.executeSql("SELECT DISTINCT listName,listColor,listDate,listFilter,favorite,userOrder,id FROM lists WHERE done=2 ORDER BY favorite DESC, listName ASC", []);
                } else if (sort===3) {
                    rs = tx.executeSql("SELECT DISTINCT listName,listColor,listDate,listFilter,favorite,userOrder,id FROM lists WHERE done=2 ORDER BY userOrder ASC ,id DESC", []);
                } else {
                    rs = tx.executeSql("SELECT DISTINCT listName,listColor,listDate,listFilter,favorite,userOrder,id FROM lists WHERE done=2 ORDER BY favorite DESC, id ASC", []);
                }
                listModel.clear();
                if (rs.rows.length > 0) {
                    var item
                    var listCount
                    var listDone
                    for (var i=0; i<rs.rows.length; ++i) {
                        item = rs.rows.item(i);
                        listCount = tx.executeSql("SELECT taskName FROM lists WHERE listName=? AND listDate=? AND done!=2", [item.listName, item.listDate]);
                        listDone = tx.executeSql("SELECT taskName FROM lists WHERE listName=? AND listDate=? AND done=1", [item.listName, item.listDate]);
                        listModel.append({
                            "listName": item.listName,
                            "listColor": item.listColor,
                            "listDate": item.listDate,
                            "listCount": listCount.rows.length,
                            "listDone": listDone.rows.length,
                            "listFilter": item.listFilter,
                            "favorite": item.favorite,
                            "userOrder": item.userOrder,
                            "id": item.id
                        })
                    }
                }
                updateNumberOfLists();
            }
        )
    }

    function fillTaskModel(listName, listDate, listColor,searchTask) {
        var searchTerm = ""
        if (searchTask) searchTerm = " AND taskName LIKE '%"+searchTask+"%' "
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs
                var sort = Settings.getSortingTasks()
                if (sort===1) {
                    rs = tx.executeSql("SELECT taskName,done,listColor FROM lists WHERE listName=? AND listDate=? AND done!=2 "+searchTerm+" ORDER BY done ASC, id DESC", [listName, listDate]);
                } else if (sort===2) {
                    rs = tx.executeSql("SELECT taskName,done,listColor FROM lists WHERE listName=? AND listDate=? AND done!=2 "+searchTerm+" ORDER BY done ASC, taskName ASC", [listName, listDate]);
                } else {
                    rs = tx.executeSql("SELECT taskName,done,listColor FROM lists WHERE listName=? AND listDate=? AND done!=2 "+searchTerm+" ORDER BY done ASC, id ASC", [listName, listDate]);
                }
                listModel.clear();
                if (rs.rows.length > 0) {
                    var item
                    for (var i=0; i<rs.rows.length; ++i) {
                        item = rs.rows.item(i);
                        listModel.append({
                            "taskName": item.taskName,
                            "done": item.done
                        })
                    }
                }
                curColor = listColor
                curListName = listName;
                curDate = listDate;
                updateNumberOfTasks(listName, listDate);
                updateNumberOfDone(listName, listDate);
            }
        )
    }

    function fillFilteredTaskModel(completedFlag, uncompletedFlag, sortingOrder) {
        //console.log("sortingOrder model: ", sortingOrder)
        if (completedFlag || uncompletedFlag) {
            var db = openDb()
            db.transaction(
                function(tx) {
                    var rs
                    if (sortingOrder===1) {
                        if (!completedFlag) {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND done=0 AND listFilter=1 ORDER BY done ASC, id DESC");
                        } else if (!uncompletedFlag) {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND done=1 AND listFilter=1 ORDER BY done ASC, id DESC");
                        } else {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND listFilter=1 ORDER BY done ASC, id DESC");
                        }
                    } else {
                        if (!completedFlag) {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND done=0 AND listFilter=1 ORDER BY done ASC, id ASC");
                        } else if (!uncompletedFlag) {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND done=1 AND listFilter=1 ORDER BY done ASC, id ASC");
                        } else {
                            rs = tx.executeSql("SELECT listName,taskName,done,listDate FROM lists WHERE done!=2 AND listFilter=1 ORDER BY done ASC, id ASC");
                        }
                    }

                    listModel.clear();
                    if (completedFlag && uncompletedFlag) {
                        doneCount = 0;
                        undoneCount = 0;
                    }
                    if (rs.rows.length > 0) {
                        //console.log(rs.rows.length)
                        var item
                        for (var i=0; i<rs.rows.length; ++i) {
                            item = rs.rows.item(i);

                            if (completedFlag && uncompletedFlag) {
                                if (item.done==1) {
                                    doneCount++;
                                } else {
                                    undoneCount++;
                                }
                            }

                            listModel.append({
                                "listName": item.listName,
                                "taskName": item.taskName,
                                "done": item.done,
                                "listDate": item.listDate
                            })
                        }
                    }
                }
            )
        } else {
            listModel.clear();
        }
    }

    function filterSeparator(index, completedFlag, uncompletedFlag, sortingOrder) {
        //console.log("sortingOrder separ: ", sortingOrder)
        var flag
        var db = openDb()
        if (completedFlag || uncompletedFlag) {
            db.transaction(
                function(tx) {
                    var rs
                    if (sortingOrder===1) {
                        if (!completedFlag) {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND done=1 AND listFilter=1 ORDER BY done ASC, id DESC");
                        } else if (!uncompletedFlag) {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND done=0 AND listFilter=1 ORDER BY done ASC, id DESC");
                        } else {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND listFilter=1 ORDER BY done ASC, id DESC");
                        }
                    } else {
                        if (!completedFlag) {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND done=1 AND listFilter=1 ORDER BY done ASC, id ASC");
                        } else if (!uncompletedFlag) {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND done=0 AND listFilter=1 ORDER BY done ASC, id ASC");
                        } else {
                            rs = tx.executeSql("SELECT listName FROM lists WHERE done!=2 AND listFilter=1 ORDER BY done ASC, id ASC");
                        }
                    }

                    if (rs.rows.length > 0) {
                        var curList;
                        if (rs.rows.item(index)) {
                            curList = rs.rows.item(index).listName;
                        }
                        var previewList;
                        if (rs.rows.item(index+1)) {
                            previewList = rs.rows.item(index+1).listName;
                        }
                        if (curList && previewList && curList!==previewList) {
                            flag = true;
                        } else {
                            flag = false;
                        }
                    }
                }
            )
        } else {
            flag = false;
        }

        //console.log("index: ", index);
        return flag;
    }

    function getName(index) {
        var rs = listModel.get(index);
        if (rs.listName) {
            //console.log("rs: ", rs.listName)
            return rs.listName
        } else if (rs.taskName) {
            return rs.taskName
        } else {
            return 0
        }
    }

    function getListName(index) {
        var rs = listModel.get(index);
        return rs.listName
    }

    function getTaskName(index) {
        var rs = listModel.get(index);
        return rs.taskName
    }

    function getDone(index) {
        var rs = listModel.get(index);
        return rs.done
    }

    function getColor(index) {
        var rs = listModel.get(index);
        return rs.listColor
    }

    function getDate(index) {
        var rs = listModel.get(index);
        return rs.listDate
    }

    function updateNumberOfLists() {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT id FROM lists WHERE done=2");
                listsCount = rs.rows.length;
            }
        )
    }

    function updateNumberOfTasks(listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT DISTINCT taskName FROM lists WHERE listName=? AND listDate=?", [listName, listDate]);
                tasksCount = rs.rows.length;
            }
        )
    }

    function updateNumberOfDone(listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT * FROM lists WHERE done=1 AND listName=? AND listDate=?", [listName, listDate]);
                doneCount = rs.rows.length;
            }
        )
    }

    function addList(listName) {
        var db = openDb()
        var listColor
        var curDate
        var id
        var newTaskString
        db.transaction(
            function(tx) {
                var index
                var availableColors = [
                    "#cc0000", "#cc7700", "#ccbb00",
                    "#88cc00", "#00b315", "#00bf9f",
                    "#005fcc", "#0016de", "#bb00cc"]

                var r = tx.executeSql("SELECT value FROM next_color_index LIMIT 1")
                index = parseInt(r.rows.item(0).value, 10)
                if (index >= availableColors.length)
                    index = 0
                tx.executeSql("UPDATE next_color_index SET value = ?", [index + 1])

                listColor = availableColors[index];
                curDate = new Date().toLocaleString(Qt.locale(),"dd MMM yyyy, hh:mm");
                id = new Date().toLocaleString(Qt.locale(),"yyyyMMddhhmmss") + "00";
                //console.log("id: ", id)
                tx.executeSql("INSERT INTO lists VALUES(?,?,?,2,?,?,1,0,0)", [listName,listColor,listName,curDate,id]);
                //newTaskString = "INSERT INTO lists VALUES(" + listName + "," + listColor +"," + taskNameArr[i] + ",0," + listDate + "," + id + ",2,2,0)"
                //fillTaskModel(listName, listDate);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, curDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
        var data = {
            color: listColor,
            date: curDate,
            id: id
        }

        return data;
    }

    function addTask(listName, listColor, taskName, listDate) {
        var db = openDb();
        var newTaskString = [];
        var listId;
        db.transaction(
            function(tx) {
                var taskNameArr = taskName.split('\n')
                for (var i=0;i<taskNameArr.length;i++) {
                    var id
                    if (i<10) {
                        id = new Date().toLocaleString(Qt.locale(),"yyyyMMddhhmmss") + "0" + i.toString()
                    } else {
                        id = new Date().toLocaleString(Qt.locale(),"yyyyMMddhhmmss") + i.toString()
                    }
                    var rs = tx.executeSql("SELECT id FROM lists WHERE done!=2 AND listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                    if (rs.rows.length>0) {
                        tx.executeSql("UPDATE lists SET id=? WHERE id=?", [id, rs.rows.item(0).id]);
                        tx.executeSql("UPDATE lists SET done=0 WHERE id=?", [id]);
                    } else {
                        tx.executeSql("INSERT INTO lists VALUES(?,?,?,0,?,?,2,2,0)", [listName, listColor, taskNameArr[i], listDate,id]);
                    }
                }
                fillTaskModel(listName, listDate, listColor);
                var rs1 = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs1.rows.item(0).id)
            }
        )
    }

    function renameList(oldName, newName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("UPDATE lists SET listName=? WHERE listName=? AND listDate=?", [newName, oldName, listDate]);
                fillListModel();
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [newName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function renameTask(oldName, newName, listName, listDate, listColor) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("UPDATE lists SET taskName=? WHERE taskName=? AND listName=? AND listDate=?", [newName, oldName, listName, listDate]);
                fillTaskModel(listName, listDate, listColor);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function updateColor(newColor, listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("UPDATE lists SET listColor=? WHERE listName=? AND listDate=?", [newColor, listName, listDate]);
                fillTaskModel(listName, listDate, newColor);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function checkAndAdd(name) {
        var found = mainWindow.idForUpdate.some(function (el) {
            return el === name;
        });
        if (!found) {
            mainWindow.idForUpdate.push(name);
            Settings.setLocalDatabaseStatus(mainWindow.idForUpdate.toString());
        }
    }

    function updateStatus(index, listName, listDate, listColor, taskName, done) {
        var db = openDb()
        db.transaction(
            function(tx) {
                if(done) {
                    tx.executeSql("UPDATE lists set done=1 where listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                } else {
                    tx.executeSql("UPDATE lists set done=0 where listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                }
                if(done) {
                    listModel.setProperty(index, "done", 1);
                } else {
                    listModel.setProperty(index, "done", 0);
                }
                fillTaskModel(listName, listDate, listColor);
                updateNumberOfDone(listName, listDate);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function updateStatusForFiltering(index, listName, listDate, taskName, done, completedFlag, uncompletedFlag, sortingOrder) {
        var db = openDb()
        db.transaction(
            function(tx) {
                if(done) {
                    tx.executeSql("UPDATE lists SET done=1 WHERE listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                } else {
                    tx.executeSql("UPDATE lists SET done=0 WHERE listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                }
                if(done) {
                    listModel.setProperty(index, "done", 1);
                } else {
                    listModel.setProperty(index, "done", 0);
                }
                fillFilteredTaskModel(completedFlag, uncompletedFlag, sortingOrder);
                //updateNumberOfDone(listName, listDate);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function deleteList(index, listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("DELETE FROM lists WHERE listName=? AND listDate=?", [listName, listDate]);
                listModel.remove(index);
                updateNumberOfLists();
            }
        )
    }

    function deleteTask(index, listName, listDate, taskName) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("DELETE FROM lists WHERE listName=? AND listDate=? AND taskName=?", [listName, listDate, taskName]);
                listModel.remove(index);
                updateNumberOfTasks(listName, listDate);
                var rs = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs.rows.item(0).id)
            }
        )
    }

    function compliteAllTasks(listName, listDate, listColor) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("UPDATE lists set done=1 where listName=? AND listDate=? AND done=0", [listName, listDate]);
                fillTaskModel(listName, listDate, listColor);
            }
        )
    }

    function clearDoneTasks(listName, listDate, listColor) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("DELETE FROM lists WHERE done=1 AND listName=? AND listDate=?", [listName, listDate]);
                fillTaskModel(listName, listDate, listColor);
            }
        )
    }

    function clearList(listName, listDate, listColor) {
        var db = openDb()
        db.transaction(
            function(tx) {
                tx.executeSql("DELETE FROM lists WHERE done!=2 AND listName=? AND listDate=?", [listName, listDate]);
                fillTaskModel(listName, listDate, listColor);
            }
        )
    }

    function setListFilter(listFilter, listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                var newFilter;
                if (listFilter) {
                    newFilter = 1;
                } else {
                    newFilter = 0;
                }
                tx.executeSql("UPDATE lists SET listFilter=? WHERE listName=? AND listDate=?", [newFilter, listName, listDate]);
            }
        )
    }

    function copyTasks(senderData, receiverName, receiverDate, receiverColor) {
        var senderName = senderData[0];
        var senderDate = senderData[1];
        var senderTasks = [];
        for (var i=0;i<senderData.length-2;i++) {
            senderTasks.push(senderData[i+2]);
        }

        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT taskName,done FROM lists WHERE listName=? AND listDate=? AND done!=2 ORDER BY done ASC, id ASC", [senderName, senderDate]);
                console.log("rs.rows.length: ", rs.rows.length)
                if (rs.rows.length > 0) {
                    var item
                    for (var i=0; i<rs.rows.length; ++i) {
                        if (senderTasks[i]===1) {
                            item = rs.rows.item(i);
                            var id = new Date().toLocaleString(Qt.locale(),"yyyyMMddhhmmss") + "00";
                            tx.executeSql("INSERT INTO lists VALUES(?,?,?,?,?,?,2,2,0)", [receiverName, receiverColor, item.taskName, item.done, receiverDate, id]);
                        }
                    }
                }
                updateNumberOfTasks(receiverName, receiverDate);
                updateNumberOfDone(receiverName, receiverDate);
                var rs1 = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [receiverName, receiverDate])
                checkAndAdd(rs1.rows.item(0).id)
            }
        )
    }

    function changeFavorite(listName, listDate) {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT favorite FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate]);
                if(rs.rows.item(0).favorite==1) {
                    tx.executeSql("UPDATE lists set favorite=0 where listName=? AND listDate=? AND done=2", [listName, listDate]);
                } else {
                    tx.executeSql("UPDATE lists set favorite=1 where listName=? AND listDate=? AND done=2", [listName, listDate]);
                }
                var rs1 = tx.executeSql("SELECT id FROM lists WHERE listName=? AND listDate=? AND done=2", [listName, listDate])
                checkAndAdd(rs1.rows.item(0).id)
            }
        )
    }

    function getAllTasks() {
        var tasksCount
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT taskName FROM lists WHERE done!=2");
                tasksCount = rs.rows.length;
            }
        )

        return tasksCount
    }

    function getAllDoneTasks() {
        var tasksCount
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT taskName FROM lists WHERE done=1");
                tasksCount = rs.rows.length;
            }
        )

        return tasksCount
    }

    function getAllUndoneTasks() {
        var tasksCount
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT taskName FROM lists WHERE done=0");
                tasksCount = rs.rows.length;
            }
        )

        return tasksCount
    }

    function createJSON() {
        var db = openDb();
        //var lists = [];
        //var tablesCount;
        var tablesName = "";
        var result = [];
        db.transaction(
            function(tx) {
                var rs;
                var item = [];
                var i;
                console.log("listsForUpdate.length: ",mainWindow.idForUpdate.length)
                if (mainWindow.idForUpdate.length>0) {
                    for (i=0;i<mainWindow.idForUpdate.length;i++) {
                        rs = tx.executeSql("SELECT id,listName,listColor,listDate,listFilter,favorite,userOrder FROM lists WHERE done=2 AND id=? ORDER BY id ASC", [mainWindow.idForUpdate[i]]);
                        item.push(rs.rows.item(0));
                    }
                } else {
                    rs = tx.executeSql("SELECT id,listName,listColor,listDate,listFilter,favorite,userOrder FROM lists WHERE done=2 ORDER BY id ASC");
                    if (rs.rows.length > 0) {
                        for (i=0; i<rs.rows.length; ++i) {
                            item.push(rs.rows.item(i));
                        }
                    }
                }
                //tablesCount = rs.rows.length;

                //if (rs.rows.length > 0) {
                    //var item;
                    for (i=0; i<item.length; ++i) {
                        var list = [];
                        //item = rs.rows.item(i);
                        var rs1 = tx.executeSql("SELECT id,taskName,done FROM lists WHERE listName=? AND listDate=? AND done!=2 ORDER BY id ASC", [item[i].listName, item[i].listDate]);
                        var tasksCount = rs1.rows.length;

                        tablesName += item[i].id + "\n";

                        list.push({
                            "id": item[i].id,
                            "listName": item[i].listName,
                            "listColor": item[i].listColor,
                            "listDate": item[i].listDate,
                            "listFilter": item[i].listFilter,
                            "favorite": item[i].favorite,
                            "userOrder": item[i].userOrder,
                            "tasksCount": tasksCount
                        })

                        if (rs1.rows.length > 0) {
                            var item1;
                            for (var j=0; j<rs1.rows.length; ++j) {
                                item1 = rs1.rows.item(j);
                                list.push({
                                    "id": item1.id,
                                    "taskName": item1.taskName,
                                    "done": item1.done
                                })
                            }
                        }
                        //list = JSON.stringify(item)
                        result.push(JSON.stringify(list));
                    }
                //}
            }
        )

        var summary = "dbVersion: " + dbVersionForDbox + "\n" + "tableCount: " + listsCount + "\n" + tablesName
        result.push(summary)

        return result;
    }

    function importData(newLists) {
        var db = openDb();
        var list;
        var listsCount1 = Object.keys(newLists).length;

        for (var i=0;i<listsCount1;i++) {
            try {
                list = JSON.parse(newLists[i]);
            } catch (error) {
                console.log("error in parse");
                return false;
            }

            db.transaction(function(tx) {
                //var i,j;
                var rs = tx.executeSql("SELECT id FROM lists WHERE id=?",[list[0].id]);
                if (rs.rows.item(0)) {
                    //console.log("list exist")
                    tx.executeSql("DELETE FROM lists WHERE listName=? AND listDate=? AND done!=2", [list[0].listName,list[0].listDate]);
                    for (var j=1;j<list[0].tasksCount+1;j++) {
                        tx.executeSql("INSERT INTO lists VALUES(?,?,?,?,?,?,2,2,0)", [list[0].listName, list[0].listColor, list[j].taskName, list[j].done, list[0].listDate, list[j].id]);
                        //console.log("add task: ", list[0].listName, list[0].listColor, list[j].taskName, list[j].done, list[0].listDate, list[j].id)
                    }
                } else {
                    //console.log("list not exist")
                    tx.executeSql("INSERT INTO lists VALUES(?,?,?,2,?,?,?,?,?)", [list[0].listName, list[0].listColor, list[0].listName, list[0].listDate, list[0].id, list[0].listFilter, list[0].favorite, list[0].userOrder]);
                    //console.log("add list: ", list[0].listName, list[0].listColor, list[0].listName, list[0].listDate, list[0].id, list[0].listFilter, list[0].favorite, list[0].userOrder)
                    for (var j=1;j<list[0].tasksCount+1;j++) {
                        tx.executeSql("INSERT INTO lists VALUES(?,?,?,?,?,?,2,2,0)", [list[0].listName, list[0].listColor, list[j].taskName, list[j].done, list[0].listDate, list[j].id]);
                        //console.log("add task: ", list[0].listName, list[0].listColor, list[j].taskName, list[j].done, list[0].listDate, list[j].id)
                    }
                }
            })
        }
        fillListModel();

        return true;
    }

    function initiateUserOrder() {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT id,userOrder FROM lists WHERE done=2 ORDER BY userOrder ASC ,id DESC");

                if (rs.rows.length > 0) {
                    var id
                    for (var i=0; i<rs.rows.length; ++i) {
                        id = rs.rows.item(i).id;
                        //console.log("id: ",id, " userOrder: ", rs.rows.item(i).userOrder)
                        tx.executeSql("UPDATE lists set userOrder=? WHERE id=?", [i, id]);
                        //listModel
                    }
                }

                /*var rs = tx.executeSql("SELECT userOrder FROM lists WHERE done=2 ORDER BY userOrder ASC ,id DESC");
                for (var i=0; i<rs.rows.length; ++i) {
                    console.log("userOrder_init: ", rs.rows.item(i).userOrder)
                }*/

            }
        )
        fillListModel();
        //getNewOrder();
    }

    function getNewOrder() {
        //console.log("listModel.count: ",listModel.count)
        for (var i=0;i<listModel.count;i++) {
            console.log("listModel.userOrder: ",listModel.get(i).userOrder)
        }
    }

    function setUserOrder(newOrder) {
        var db = openDb()
        db.transaction(
            function(tx) {
                var rs = tx.executeSql("SELECT id,userOrder FROM lists WHERE done=2 ORDER BY userOrder ASC");
                if (rs.rows.length > 0) {
                    var id
                    var userOrder
                    var newIndex = []
                    for (var i=0; i<rs.rows.length; ++i) {
                        id = rs.rows.item(i).id;
                        userOrder = rs.rows.item(i).userOrder;
                        //console.log("newOrder: ",newOrder[i])
                        for (var j=0;j<newOrder.length;j++) {
                            if (userOrder===newOrder[j]) {
                                newIndex.push(j);
                                break;
                            }
                        }
                        //console.log("userOrder: ",userOrder, " - > ",newIndex[i])
                        //console.log("id: ",id)
                        tx.executeSql("UPDATE lists set userOrder=? WHERE id=?", [newIndex[i], id]);
                    }
                }

                /*var rs = tx.executeSql("SELECT id,userOrder FROM lists WHERE done=2 ORDER BY userOrder ASC ,id DESC", []);
                for (var i=0; i<rs.rows.length; ++i) {
                    console.log("userOrder_new: ", rs.rows.item(i).userOrder)
                    console.log("id_new: ", rs.rows.item(i).id)
                }*/
            }
        )
        fillListModel();
    }

    Component.onCompleted: {
        fillListModel();
    }
}
