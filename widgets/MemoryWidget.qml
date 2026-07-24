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
        if (!text) return { ram: 0, swap: 0 };
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
        
        var ramUsed = 0;
        if (memTotal > 0) {
            ramUsed = Math.round((1 - memAvailable / memTotal) * 100);
        }
        
        var swapUsed = 0;
        if (swapTotal > 0) {
            swapUsed = Math.round((1 - swapFree / swapTotal) * 100);
        }
        
        return { ram: ramUsed, swap: swapUsed };
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
    width: memoryRow.implicitWidth + 28
    height: 22
    radius: 11
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: memoryRow
        anchors.centerIn: parent
        spacing: 6

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
        onEntered: memoryPill.color = Theme.pillBgHover
        onExited: memoryPill.color = Theme.pillBg
    }
}
