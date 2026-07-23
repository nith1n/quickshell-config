// RightSidebar.qml
import Quickshell
import QtQuick
import "../helpers"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                right: true
                top: true
                bottom: true
            }

            implicitWidth: Theme.rightSidebarWidth
            color: Theme.barBg
            exclusiveZone: Theme.rightSidebarWidth
        }
    }
}
