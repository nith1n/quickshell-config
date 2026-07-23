// Sidebar.qml
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
                left: true
                top: true
                bottom: true
            }

            implicitWidth: Theme.leftSidebarWidth
            color: Theme.barBg
            exclusiveZone: Theme.leftSidebarWidth
        }
    }
}
