// ActiveTitleWidget.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../helpers"

Text {
    id: activeTitle
    text: {
        var active = Hyprland.activeToplevel;
        var focused = Hyprland.focusedWorkspace;
        if (active && focused && active.workspace && active.workspace.id === focused.id) {
            return active.title;
        }
        return "";
    }
    color: Theme.textMuted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
    elide: Text.ElideRight
    width: 250
    anchors.verticalCenter: parent.verticalCenter
}
