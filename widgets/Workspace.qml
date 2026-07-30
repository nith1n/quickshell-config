// Workspace.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../helpers"

Item {
    id: root
    implicitWidth: wsRow.implicitWidth
    implicitHeight: Theme.wsSize

    // Sliding Active Accent Pill
    Rectangle {
        id: activeIndicator
        width: Theme.wsSize
        height: Theme.wsSize
        radius: Theme.wsRadius
        color: Theme.accent
        visible: Hyprland.focusedWorkspace !== null
        z: 0

        // Smooth sliding animation when switching workspaces
        Behavior on x {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }
    }

    Row {
        id: wsRow
        spacing: Theme.wsSpacing
        z: 1

        Repeater {
            model: Hyprland.workspaces.values

            Rectangle {
                id: ws
                width: Theme.wsSize
                height: Theme.wsSize
                radius: Theme.wsRadius

                property bool active: Hyprland.focusedWorkspace?.id === modelData.id
                property bool haveWindows: modelData.toplevels.values.length > 0

                // Inactive workspace colors (active state is covered by activeIndicator)
                color: haveWindows && !active ? Theme.pillBg : "transparent"
                border.width: 0

                // Synchronize activeIndicator position on workspace switch
                onActiveChanged: {
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
