import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../helpers"

Row {
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: ws
            width: 20
            height: 20
            radius: 10

            property bool active: Hyprland.focusedWorkspace?.id === modelData.id
            property bool haveWindows: modelData.toplevels.values.length > 0

            // Dark theme dynamic colors
            color: active ? Theme.accent : (haveWindows ? Theme.pillBg : 'transparent')
            border.width: 0

            // Smooth background transition animation
            Behavior on color {
                ColorAnimation { duration: 180 }
            }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                color: active ? Theme.barBg : (haveWindows ? Theme.text : Theme.textMuted)
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
            }
        }
    }
}
