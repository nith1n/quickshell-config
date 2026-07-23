// BatteryWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: batteryPill

    // Properties
    readonly property string capacityText: capacityFile.text() ? capacityFile.text().trim() : "100"
    readonly property string statusText: statusFile.text() ? statusFile.text().trim() : "Unknown"

    // Functions
    function getBatteryIcon(percentageStr, status) {
        if (status === "Charging") {
            return "../icons/battery-charging.svg";
        }
        return "../icons/battery.svg";
    }

    // Helper functions for status & icon formatting
    function getIconColor(percentageStr, status) {
        var p = parseInt(percentageStr);
        if (isNaN(p)) p = 100;

        if (status === "Charging") {
            return Theme.success;
        }
        if (p < 20) {
            return Theme.danger;
        }
        return Theme.accent;
    }

    // Backend Helpers & Resources
    FileView {
        id: capacityFile
        path: "/sys/class/power_supply/BAT0/capacity"
    }

    FileView {
        id: statusFile
        path: "/sys/class/power_supply/BAT0/status"
    }

    // Timer to poll sysfs nodes every 10 seconds (sysfs doesn't support inotify)
    Timer {
        id: pollTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            capacityFile.reload()
            statusFile.reload()
        }
    }

    // Widget Dimensions & Styling
    width: batteryRow.implicitWidth + 28
    height: 22
    radius: 11
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            source: batteryPill.getBatteryIcon(batteryPill.capacityText, batteryPill.statusText)
            color: batteryPill.getIconColor(batteryPill.capacityText, batteryPill.statusText)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: batteryPill.capacityText + "%"
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
        onEntered: batteryPill.color = Theme.pillBgHover
        onExited: batteryPill.color = Theme.pillBg
    }
}
