// MemoryWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: memoryPill

    // Properties
    readonly property string meminfoText: meminfoFile.text() ? meminfoFile.text() : ""
    readonly property var memData: parseMeminfo(meminfoText)

    // Functions
    function parseMeminfo(text) {
        if (!text) {
            return {
                ram: 0,
                ramUsedGB: "0.0",
                ramTotalGB: "0.0",
                ramRatio: 0,
                swap: 0,
                swapUsedGB: "0.0",
                swapTotalGB: "0.0",
                swapRatio: 0
            };
        }
        var lines = text.split("\n");
        var memTotal = 0;
        var memAvailable = 0;
        var swapTotal = 0;
        var swapFree = 0;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            if (line.startsWith("MemTotal:")) {
                memTotal = parseInt(line.match(/\d+/)[0]);
            } else if (line.startsWith("MemAvailable:")) {
                memAvailable = parseInt(line.match(/\d+/)[0]);
            } else if (line.startsWith("SwapTotal:")) {
                swapTotal = parseInt(line.match(/\d+/)[0]);
            } else if (line.startsWith("SwapFree:")) {
                swapFree = parseInt(line.match(/\d+/)[0]);
            }
        }

        var ramUsed = Math.max(0, memTotal - memAvailable);
        var ramPercent = memTotal > 0 ? Math.round((ramUsed / memTotal) * 100) : 0;
        var ramUsedGB = (ramUsed / 1048576).toFixed(1);
        var ramTotalGB = (memTotal / 1048576).toFixed(1);

        var swapUsed = Math.max(0, swapTotal - swapFree);
        var swapPercent = swapTotal > 0 ? Math.round((swapUsed / swapTotal) * 100) : 0;
        var swapUsedGB = (swapUsed / 1048576).toFixed(1);
        var swapTotalGB = (swapTotal / 1048576).toFixed(1);

        return {
            ram: ramPercent,
            ramUsedGB: ramUsedGB,
            ramTotalGB: ramTotalGB,
            ramRatio: memTotal > 0 ? (ramUsed / memTotal) : 0,
            swap: swapPercent,
            swapUsedGB: swapUsedGB,
            swapTotalGB: swapTotalGB,
            swapRatio: swapTotal > 0 ? (swapUsed / swapTotal) : 0
        };
    }

    // Backend Helpers & Resources
    FileView {
        id: meminfoFile
        path: "/proc/meminfo"
    }

    Timer {
        interval: 5000 // poll memory info every 5 seconds
        running: true
        repeat: true
        onTriggered: meminfoFile.reload()
    }

    // Widget Dimensions & Styling
    width: memoryRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: memoryRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            source: "../icons/memory.svg"
            color: Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "RAM: " + memoryPill.memData.ram + "% / SWAP: " + memoryPill.memData.swap + "%"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Interactivity
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: {
            meminfoFile.reload();
            memoryPopup.visible = !memoryPopup.visible;
        }

        onEntered: memoryPill.color = Theme.pillBgHover
        onExited: memoryPill.color = Theme.pillBg
    }

    // -------------------------------------------------------------------------
    // Memory Details Popup
    // -------------------------------------------------------------------------

    MemoryMenu {
        id: memoryPopup
        anchor.item: memoryPill
        memData: memoryPill.memData
    }
}
