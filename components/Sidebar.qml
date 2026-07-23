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

            implicitWidth: 8
            color: Theme.barBg
            exclusiveZone: 8
        }
    }
}
