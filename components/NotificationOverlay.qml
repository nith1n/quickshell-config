// NotificationOverlay.qml
import QtQuick
import Quickshell
import "../helpers"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: toastWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                right: true
            }

            margins {
                top: Theme.topBarHeight + 12
                right: 18
            }

            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            implicitWidth: 360
            implicitHeight: toastColumn.implicitHeight + 10

            // The overlay window is only visible when there are active toasts
            visible: Notifications.popups.length > 0

            Column {
                id: toastColumn
                width: 360
                spacing: 10

                Repeater {
                    model: Notifications.popups

                    delegate: Rectangle {
                        id: toastCard
                        required property var modelData
                        property var notif: modelData

                        width: 360
                        implicitHeight: cardContent.implicitHeight + 24
                        radius: 12
                        color: Theme.pillBg
                        border.width: 1
                        border.color: notif.urgency === 2 ? Theme.danger : Qt.alpha(Theme.text, 0.1)

                        // Smooth slide/fade entry
                        opacity: 1.0
                        Behavior on opacity {
                            NumberAnimation { duration: 180 }
                        }

                        // Auto-expire timer
                        Timer {
                            interval: {
                                if (notif.expireTimeout && notif.expireTimeout > 0) {
                                    return Math.max(2000, notif.expireTimeout * 1000);
                                }
                                return 6000; // Default 6 seconds
                            }
                            running: true
                            onTriggered: {
                                Notifications.removePopup(notif);
                            }
                        }

                        function resolveIcon(iconName, imagePath) {
                            if (imagePath && imagePath.length > 0) return imagePath;
                            if (!iconName || iconName.length === 0) return "";
                            if (iconName.startsWith("/") || iconName.startsWith("file://")) return iconName;
                            return Quickshell.iconPath(iconName) || "";
                        }

                        Column {
                            id: cardContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 8

                            // Header: App Icon, App Name, Close Button
                            Item {
                                width: parent.width
                                height: 20

                                Row {
                                    anchors.left: parent.left
                                    anchors.right: closeBtn.left
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Image {
                                        id: appIcon
                                        width: 18
                                        height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: toastCard.resolveIcon(toastCard.notif.appIcon, toastCard.notif.image)
                                        fillMode: Image.PreserveAspectFit
                                        visible: status === Image.Ready
                                    }

                                    Text {
                                        visible: appIcon.status !== Image.Ready
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "󰂚"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 14
                                        color: toastCard.notif.urgency === 2 ? Theme.danger : Theme.accent
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: toastCard.notif.appName || "Notification"
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize * 0.95
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width - 26
                                    }
                                }

                                // Close Button
                                Rectangle {
                                    id: closeBtn
                                    width: 20
                                    height: 20
                                    radius: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                    color: closeMouse.containsMouse ? Qt.alpha(Theme.text, 0.1) : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 12
                                        color: closeMouse.containsMouse ? Theme.text : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Notifications.removePopup(toastCard.notif);
                                        }
                                    }
                                }
                            }

                            // Summary / Title
                            Text {
                                width: parent.width
                                visible: (toastCard.notif.summary ?? "").length > 0
                                text: toastCard.notif.summary || ""
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize * 1.1
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }

                            // Body
                            Text {
                                width: parent.width
                                visible: (toastCard.notif.body ?? "").length > 0
                                text: toastCard.notif.body || ""
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 4
                                elide: Text.ElideRight
                            }

                            // Action buttons (if any)
                            Row {
                                width: parent.width
                                spacing: 8
                                visible: toastCard.notif.actions && toastCard.notif.actions.length > 0

                                Repeater {
                                    model: toastCard.notif.actions

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: actionText.implicitWidth + 16
                                        height: 24
                                        radius: 12
                                        color: actionMouse.containsMouse ? Theme.pillBgHover : Qt.alpha(Theme.accent, 0.18)
                                        border.width: 1
                                        border.color: Theme.accent

                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: modelData.text || "Action"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize * 0.9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: actionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                modelData.invoke();
                                                Notifications.removePopup(toastCard.notif);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Clicking card body removes toast popup
                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            onClicked: {
                                Notifications.removePopup(toastCard.notif);
                            }
                        }
                    }
                }
            }
        }
    }
}
