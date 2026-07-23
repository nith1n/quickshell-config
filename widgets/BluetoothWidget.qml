// BluetoothWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: btPill

    // Properties
    property bool isPowered: false
    property bool isConnected: false
    readonly property string rfkillText: rfkillFile.text() ? rfkillFile.text().trim() : "0"

    // Functions
    function getBluetoothIcon(powered, connected) {
        return "../icons/bluetooth.svg";
    }

    function getBluetoothLabel(powered, connected) {
        if (!powered) return "Off";
        if (connected) return "Connected";
        return "On";
    }

    function getIconColor(powered, connected) {
        if (!powered) return Theme.textMuted;
        if (connected) return Theme.success;
        return Theme.accent;
    }

    // Backend Helpers & Resources
    FileView {
        id: rfkillFile
        path: "/sys/class/rfkill/rfkill0/state"
    }

    // Process to check connected devices via D-Bus ObjectManager
    Process {
        id: checkConnectedProc
        command: ["bash", "-c", "busctl call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects | grep -q '\"Connected\" b true'"]
        running: true
        onExited: (code) => {
            btPill.isConnected = (code === 0);
        }
    }

    // Process to toggle bluetooth
    Process {
        id: toggleProc
        command: ["rfkill", "toggle", "bluetooth"]
        onExited: {
            rfkillFile.reload();
            checkConnectedProc.running = true;
        }
    }

    Timer {
        interval: 5000 // poll bluetooth status every 5 seconds
        running: true
        repeat: true
        onTriggered: {
            rfkillFile.reload();
            checkConnectedProc.running = true;
        }
    }

    onRfkillTextChanged: {
        btPill.isPowered = (rfkillText === "1");
    }

    Component.onCompleted: {
        rfkillFile.reload();
        checkConnectedProc.running = true;
    }

    // Widget Dimensions & Styling
    width: btRow.implicitWidth + 28
    height: 22
    radius: 11
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: btRow
        anchors.centerIn: parent
        spacing: 6

        SvgIcon {
            source: btPill.getBluetoothIcon(btPill.isPowered, btPill.isConnected)
            color: btPill.getIconColor(btPill.isPowered, btPill.isConnected)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: btPill.getBluetoothLabel(btPill.isPowered, btPill.isConnected)
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
        onClicked: toggleProc.running = true

        onEntered: btPill.color = Theme.pillBgHover
        onExited: btPill.color = Theme.pillBg
    }
}
