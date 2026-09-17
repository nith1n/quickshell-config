// NotificationWidget.qml
import QtQuick
import Quickshell
import "../helpers"

Rectangle {
    id: notificationPill

    // -------------------------------------------------------------------------
    // Properties (bound directly to native Notifications singleton)
    // -------------------------------------------------------------------------

    readonly property int count: Notifications.trackedNotifications?.values?.length ?? 0
    readonly property bool dnd: Notifications.dnd

    // -------------------------------------------------------------------------
    // Widget Dimensions & Styling
    // -------------------------------------------------------------------------

    width: notificationRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // -------------------------------------------------------------------------
    // Visual Layout
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // Interactivity
    // -------------------------------------------------------------------------

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                notifPopup.visible = !notifPopup.visible;
            } else if (mouse.button === Qt.MiddleButton) {
                Notifications.toggleDnd();
            }
        }

        onEntered: notificationPill.color = Theme.pillBgHover
        onExited: notificationPill.color = Theme.pillBg
    }

    // -------------------------------------------------------------------------
    // Notification History Popup Menu
    // -------------------------------------------------------------------------

    NotificationMenu {
        id: notifPopup
        anchor.item: notificationPill
    }
}
