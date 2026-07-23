// Time.qml
pragma Singleton

import QtQuick

QtObject {
    id: root
    property string time: ""
    property string formattedDate: ""
    property string formattedTime: ""

    function updateTime() {
        var now = new Date();
        // Formats time exactly as: dd-MM-yyyy : hh:mm AP
        root.time = Qt.formatDateTime(now, "dd-MM-yyyy : hh:mm AP")
        root.formattedDate = Qt.formatDateTime(now, "dddd, MMMM d")
        root.formattedTime = Qt.formatDateTime(now, "hh:mm AP")
    }

    Component.onCompleted: {
        updateTime()
    }

    property Timer timer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
    }
}
