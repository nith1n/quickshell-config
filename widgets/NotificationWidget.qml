// NotificationWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: notificationPill

    // Properties
    property int count: 0
    property bool dnd: false
    property string alt: "none"

    // Subscription process for real-time SwayNC state changes
    Process {
        id: swayncSub
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    var obj = JSON.parse(line.trim());
                    if (obj) {
                        notificationPill.count = parseInt(obj.text) || 0;
                        notificationPill.alt = obj.alt || "none";
                        notificationPill.dnd = (obj.alt === "dnd" || obj.class === "dnd" || obj.alt === "dnd-none" || obj.alt === "dnd-notification");
                    }
                } catch (e) {}
            }
        }
    }

    // Toggle process to open/close the SwayNC control center
    Process {
        id: togglePanelProc
        command: ["swaync-client", "-t", "-sw"]
    }

    // Widget Dimensions & Styling
    width: notificationRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: notificationRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            id: icon
            source: "../icons/bell.svg"
            color: notificationPill.dnd ? Theme.textMuted : (notificationPill.count > 0 ? Theme.accent : Theme.text)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: notificationPill.count.toString()
            color: notificationPill.dnd ? Theme.textMuted : Theme.text
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
        onClicked: togglePanelProc.running = true

        onEntered: notificationPill.color = Theme.pillBgHover
        onExited: notificationPill.color = Theme.pillBg
    }
}
