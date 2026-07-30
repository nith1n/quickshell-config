// BottomBar.qml
import Quickshell
import QtQuick
import "../helpers"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bottomBarWindow
            required property var modelData
            screen: modelData

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: Theme.bottomBarHeight + Theme.filletRadius
            exclusiveZone: Theme.bottomBarHeight
            color: "transparent"

            // Define the clickthrough mask region
            mask: Region {
                regions: [
                    Region {
                        x: 0
                        y: Theme.filletRadius
                        width: bottomBarWindow.width
                        height: Theme.bottomBarHeight
                    },
                    Region {
                        // Left corner fillet
                        x: 0
                        y: 0
                        width: Theme.filletRadius
                        height: Theme.filletRadius
                    },
                    Region {
                        // Right corner fillet
                        x: bottomBarWindow.width - Theme.filletRadius
                        y: 0
                        width: Theme.filletRadius
                        height: Theme.filletRadius
                    }
                ]
            }

            // Solid background for the bottom bar (dark theme)
            Rectangle {
                id: barBackground
                x: 0
                y: Theme.filletRadius
                width: bottomBarWindow.width
                height: Theme.bottomBarHeight
                color: Theme.barBg
            }

            // Bottom-left corner fillet connecting bottom-bar and left sidebar
            Fillet {
                id: leftFillet
                corner: "bottom-left"
                x: 0
                y: 0
                radius: Theme.filletRadius
                color: Theme.barBg
            }

            // Bottom-right corner fillet connecting bottom-bar and right sidebar
            Fillet {
                id: rightFillet
                corner: "bottom-right"
                x: bottomBarWindow.width - Theme.filletRadius
                y: 0
                radius: Theme.filletRadius
                color: Theme.barBg
            }
        }
    }
}
