/*Interface for get and update app settings. Setting table created in TaskList.qml*/

.import QtQuick.LocalStorage 2.0 as Sql

function _rawOpenDb() {
    return Sql.LocalStorage.openDatabaseSync('TaskList', '', 'Task list', 10000);
}

function openDb() {
    return _rawOpenDb();
}

function resetSettings() {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = defValue");
        }
    )  
}

function getTimeoutLists() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'timeoutLists'");
            value = rs.rows.item(0).value;
        }
    )
    return value;
}

function getTimeoutTasks() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'timeoutTasks'");
            value = rs.rows.item(0).value;
        }
    )
    return value;
}

function getHideDate() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'hideDate'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getHideDoneTasksCover() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'hideDoneTasksCover'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getColoredNumbersInStatisic() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'coloredNumbersInStatisic'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getHideSeparatorsInFilters() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'hideSeparatorsInFilters'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getBackNavigateAtCover() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'backNavigateAtCover'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getAddListsFromMenu() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'addListsFromMenu'");
            if (rs.rows.item(0).value===1) {
                value = true;
            } else {
                value = false;
            }
        }
    )
    return value;
}

function getSortingLists() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'sortLists'");
            value = rs.rows.item(0).value;
        }
    )
    return value;
}

function getSortingTasks() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'sortTasks'");
            value = rs.rows.item(0).value;
        }
    )
    return value;
}

function getDboxToken() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT stringValue FROM settings WHERE parameter = 'dboxToken'");
            value = rs.rows.item(0).stringValue;
        }
    )
    return value;
}

function getDboxSecret() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT stringValue FROM settings WHERE parameter = 'dboxSecret'");
            value = rs.rows.item(0).stringValue;
        }
    )
    return value;
}

function getLoginStatus() {
    return (getDboxToken()!=="empty" && getDboxSecret()!=="empty")
}

function getAutoconnect2Dbox() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT value FROM settings WHERE parameter = 'autoconnect2Dbox'");
            value = rs.rows.item(0).value;
        }
    )
    return value;
}

function getLastDboxFileHash() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT stringValue FROM settings WHERE parameter = 'lastDboxFileHash'");
            value = rs.rows.item(0).stringValue;
        }
    )
    return value;
}

function getLocalDatabaseStatus() {
    var db = openDb();
    var value;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql("SELECT stringValue FROM settings WHERE parameter = 'localDatabaseStatus'");
            value = rs.rows.item(0).stringValue;
        }
    )
    return value;
}

function updateTimeoutLists(newTimeoutLists) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = ? WHERE parameter = 'timeoutLists'", [newTimeoutLists]);
        }
    )
}

function updateTimeoutTasks(newTimeoutTasks) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = ? WHERE parameter = 'timeoutTasks'", [newTimeoutTasks]);
        }
    )
}

function updateHideDate(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'hideDate'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'hideDate'");
            }
        }
    )
}

function updateHideDoneTasksCover(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'hideDoneTasksCover'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'hideDoneTasksCover'");
            }
        }
    )
}

function setColoredNumbersInStatisic(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'coloredNumbersInStatisic'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'coloredNumbersInStatisic'");
            }
        }
    )
}

function setHideSeparatorsInFilters(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'hideSeparatorsInFilters'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'hideSeparatorsInFilters'");
            }
        }
    )
}

function setBackNavigateAtCover(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'backNavigateAtCover'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'backNavigateAtCover'");
            }
        }
    )
}

function setAddListsFromMenu(newFlag) {
    var db = openDb();
    db.transaction(
        function(tx) {
            if (newFlag) {
                tx.executeSql("UPDATE settings SET value = 1 WHERE parameter = 'addListsFromMenu'");
            } else {
                tx.executeSql("UPDATE settings SET value = 0 WHERE parameter = 'addListsFromMenu'");
            }
        }
    )
}

function updateSortingLists(newSortingLists) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = ? WHERE parameter = 'sortLists'", [newSortingLists]);
        }
    )
}

function updateSortingTasks(newSortingTasks) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = ? WHERE parameter = 'sortTasks'", [newSortingTasks]);
        }
    )
}

function setDboxToken(newDboxToken) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET stringValue = ? WHERE parameter = 'dboxToken'", [newDboxToken]);
        }
    )
}

function setDboxSecret(newDboxSecret) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET stringValue = ? WHERE parameter = 'dboxSecret'", [newDboxSecret]);
        }
    )
}

function setAutoconnect2Dbox(newAutoconnect2Dbox) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET value = ? WHERE parameter = 'autoconnect2Dbox'", [newAutoconnect2Dbox]);
        }
    )
}

function setLastDboxFileHash(newLastDboxFileHash) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET stringValue = ? WHERE parameter = 'lastDboxFileHash'", [newLastDboxFileHash]);
        }
    )
}

function setLocalDatabaseStatus(newLocalDatabaseStatus) {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET stringValue = ? WHERE parameter = 'localDatabaseStatus'", [newLocalDatabaseStatus]);
        }
    )
}

function clearDropboxAccountInfo() {
    var db = openDb();
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE settings SET stringValue = 'empty' WHERE parameter = 'dboxToken'");
            tx.executeSql("UPDATE settings SET stringValue = 'empty' WHERE parameter = 'dboxSecret'");
            tx.executeSql("UPDATE settings SET stringValue = 'empty' WHERE parameter = 'lastDboxFileHash'");
            tx.executeSql("UPDATE settings SET stringValue = 'actual' WHERE parameter = 'localDatabaseStatus'");
        }
    )
}
