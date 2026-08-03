// Workspace.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../helpers"

Item {
    id: root
    implicitWidth: wsRow.implicitWidth
    implicitHeight: Theme.wsSize

    // Level 0: Inactive workspace button backgrounds
    Row {
        id: bgRow
        spacing: Theme.wsSpacing
        z: 0

        Repeater {
            model: Hyprland.workspaces.values

            Rectangle {
                width: Theme.wsSize
                height: Theme.wsSize
                radius: Theme.wsRadius
                property bool haveWindows: modelData.toplevels.values.length > 0
                color: haveWindows ? Theme.pillBg : "transparent"
            }
        }
    }

    // Level 1: Sliding Active Accent Pill (glides ON TOP of inactive backgrounds)
    Rectangle {
        id: activeIndicator
        width: Theme.wsSize
        height: Theme.wsSize
        radius: Theme.wsRadius
        color: Theme.accent
        visible: Hyprland.focusedWorkspace !== null
        z: 1

        // Smooth sliding animation across workspace buttons
        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
    }

    // Level 2: Workspace numbers & mouse interaction (above activeIndicator)
    Row {
        id: wsRow
        spacing: Theme.wsSpacing
        z: 2

        Repeater {
            model: Hyprland.workspaces.values

            Rectangle {
                id: ws
                width: Theme.wsSize
                height: Theme.wsSize
                color: "transparent"

                property bool active: Hyprland.focusedWorkspace?.id === modelData.id
                property bool haveWindows: modelData.toplevels.values.length > 0

                // Synchronize activeIndicator position on workspace switch or layout update
                onActiveChanged: {
                    if (active) {
                        activeIndicator.x = ws.x
                    }
                }

                onXChanged: {
                    if (active) {
                        activeIndicator.x = ws.x
                    }
                }

                Component.onCompleted: {
                    if (active) {
                        activeIndicator.x = ws.x
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: active ? Theme.barBg : (haveWindows ? Theme.text : Theme.textMuted)
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                    font.bold: true

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }
    }
}
