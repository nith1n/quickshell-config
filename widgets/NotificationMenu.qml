// NotificationMenu.qml
import QtQuick
import Quickshell
import "../helpers"

PopupWindow {
    id: root

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: 360
    implicitHeight: Math.min(520, menuColumn.implicitHeight + 28)
    visible: false
    color: "transparent"
    grabFocus: true

    readonly property int notifCount: Notifications.trackedNotifications?.values?.length ?? 0

    function resolveIcon(iconName, imagePath) {
        if (imagePath && imagePath.length > 0) return imagePath;
        if (!iconName || iconName.length === 0) return "";
        if (iconName.startsWith("/") || iconName.startsWith("file://")) return iconName;
        return Quickshell.iconPath(iconName) || "";
    }

    Rectangle {
        id: menuBackground
        anchors.fill: parent
        anchors.topMargin: 8
        radius: 14
        color: Theme.pillBg
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.08)

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // -----------------------------------------------------------------
            // Header: Title, Count Badge, DND Toggle, Clear All
            // -----------------------------------------------------------------
            Item {
                width: parent.width
                height: 28

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: "Notifications"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 1.15
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: root.notifCount > 0
                        width: countText.implicitWidth + 12
                        height: 18
                        radius: 9
                        color: Qt.alpha(Theme.accent, 0.2)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: root.notifCount.toString()
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 0.85
                            font.bold: true
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    // Do Not Disturb Toggle Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: dndMouse.containsMouse ? Theme.pillBgHover : (Notifications.dnd ? Qt.alpha(Theme.accent, 0.2) : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: Notifications.dnd ? "󰂛" : "󰂚"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: Notifications.dnd ? Theme.accent : Theme.textMuted
                        }

                        MouseArea {
                            id: dndMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.toggleDnd()
                        }
                    }

                    // Clear All Button
                    Rectangle {
                        visible: root.notifCount > 0
                        width: 28
                        height: 28
                        radius: 14
                        color: clearMouse.containsMouse ? Theme.pillBgHover : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰃢"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 15
                            color: clearMouse.containsMouse ? Theme.danger : Theme.textMuted
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.clearAll()
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.alpha(Theme.text, 0.08)
            }

            // -----------------------------------------------------------------
            // Empty State
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                height: 120
                visible: root.notifCount === 0
                spacing: 8

                Item { width: 1; height: 16 }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰂚"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 32
                    color: Qt.alpha(Theme.textMuted, 0.5)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            // -----------------------------------------------------------------
            // Notification List
            // -----------------------------------------------------------------
            ListView {
                id: notifList
                width: parent.width
                height: Math.min(360, contentHeight)
                visible: root.notifCount > 0
                clip: true
                spacing: 8
                model: Notifications.trackedNotifications ? Notifications.trackedNotifications.values : []

                delegate: Rectangle {
                    id: itemCard
                    required property var modelData
                    property var notif: modelData

                    width: notifList.width
                    implicitHeight: itemColumn.implicitHeight + 20
                    radius: 10
                    color: Qt.alpha(Theme.text, 0.04)
                    border.width: 1
                    border.color: notif.urgency === 2 ? Theme.danger : Qt.alpha(Theme.text, 0.06)

                    Column {
                        id: itemColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 6

                        // Header Row
                        Item {
                            width: parent.width
                            height: 18

                            Row {
                                anchors.left: parent.left
                                anchors.right: dismissBtn.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8

                                Image {
                                    id: cardAppIcon
                                    width: 16
                                    height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: root.resolveIcon(itemCard.notif.appIcon, itemCard.notif.image)
                                    fillMode: Image.PreserveAspectFit
                                    visible: status === Image.Ready
                                }

                                Text {
                                    visible: cardAppIcon.status !== Image.Ready
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "󰂚"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 13
                                    color: itemCard.notif.urgency === 2 ? Theme.danger : Theme.accent
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: itemCard.notif.appName || "Notification"
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize * 0.9
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width - 24
                                }
                            }

                            Rectangle {
                                id: dismissBtn
                                width: 18
                                height: 18
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                color: dismissMouse.containsMouse ? Qt.alpha(Theme.text, 0.1) : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 11
                                    color: dismissMouse.containsMouse ? Theme.text : Theme.textMuted
                                }

                                MouseArea {
                                    id: dismissMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: itemCard.notif.dismiss()
                                }
                            }
                        }

                        // Summary
                        Text {
                            width: parent.width
                            visible: (itemCard.notif.summary ?? "").length > 0
                            text: itemCard.notif.summary || ""
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 1.05
                            font.bold: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // Body
                        Text {
                            width: parent.width
                            visible: (itemCard.notif.body ?? "").length > 0
                            text: itemCard.notif.body || ""
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 0.95
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }

                        // Actions
                        Row {
                            width: parent.width
                            spacing: 6
                            visible: itemCard.notif.actions && itemCard.notif.actions.length > 0

                            Repeater {
                                model: itemCard.notif.actions

                                delegate: Rectangle {
                                    required property var modelData
                                    width: actionBtnText.implicitWidth + 14
                                    height: 22
                                    radius: 11
                                    color: actionBtnMouse.containsMouse ? Theme.pillBgHover : Qt.alpha(Theme.accent, 0.16)
                                    border.width: 1
                                    border.color: Theme.accent

                                    Text {
                                        id: actionBtnText
                                        anchors.centerIn: parent
                                        text: modelData.text || "Action"
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize * 0.85
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: actionBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
