// WifiWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: wifiPill

    // Properties
    property string status: "disabled"
    property string ssid: ""
    property int signalStrength: 0

    // Functions
    function parseWifi(text) {
        if (!text) return;
        var s = text.trim();
        var parts = s.split(":");
        if (parts[0] === "yes") {
            wifiPill.status = "connected";
            wifiPill.ssid = parts[1] || "Unknown";
            wifiPill.signalStrength = parseInt(parts[2]) || 0;
        } else if (parts[0] === "disconnected") {
            if (parts[1] === "enabled") {
                wifiPill.status = "disconnected";
            } else {
                wifiPill.status = "disabled";
            }
            wifiPill.ssid = "";
            wifiPill.signalStrength = 0;
        }
    }

    function getWifiIcon(statusVal, strength) {
        if (statusVal === "disabled" || statusVal === "disconnected") return "../icons/wifi-off.svg";
        return "../icons/wifi.svg";
    }

    // Helper functions for status & icon formatting
    function getIconColor(statusVal) {
        if (statusVal === "disabled") return Theme.textMuted;
        if (statusVal === "connected") return Theme.accent;
        return Theme.accent;
    }

    function getWifiLabel(statusVal, ssidVal) {
        if (statusVal === "disabled") return "Off";
        if (statusVal === "connected") return ssidVal;
        return "Disconnected";
    }

    // Backend Helpers & Resources
    Process {
        id: wifiStatusProc
        command: ["bash", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes:' || echo \"disconnected:$(nmcli radio wifi)\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: wifiPill.parseWifi(this.text)
        }
    }

    Timer {
        interval: 5000 // poll wifi status every 5 seconds
        running: true
        repeat: true
        onTriggered: wifiStatusProc.running = true
    }

    Component.onCompleted: {
        wifiStatusProc.running = true
    }

    // Widget Dimensions & Styling
    width: wifiRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: wifiRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            source: wifiPill.getWifiIcon(wifiPill.status, wifiPill.signalStrength)
            color: wifiPill.getIconColor(wifiPill.status)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: wifiPill.getWifiLabel(wifiPill.status, wifiPill.ssid)
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Interactivity (Read-Only, hover highlights only)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: wifiPill.color = Theme.pillBgHover
        onExited: wifiPill.color = Theme.pillBg
    }
}
