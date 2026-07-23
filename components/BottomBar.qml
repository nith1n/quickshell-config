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

            implicitHeight: 20 // 8px bar + 12px corner radius
            exclusiveZone: 8   // Reserve 8px space at the bottom of the screen
            color: "transparent"

            // Define the clickthrough mask region
            mask: Region {
                regions: [
                    Region {
                        x: 0
                        y: 12
                        width: bottomBarWindow.width
                        height: 8
                    },
                    Region {
                        // Left corner fillet
                        x: 0
                        y: 0
                        width: 12
                        height: 12
                    },
                    Region {
                        // Right corner fillet
                        x: bottomBarWindow.width - 12
                        y: 0
                        width: 12
                        height: 12
                    }
                ]
            }

            // Solid background for the bottom bar (dark theme)
            Rectangle {
                id: barBackground
                x: 0
                y: 12
                width: bottomBarWindow.width
                height: 8
                color: Theme.barBg
            }

            // Bottom-left corner fillet connecting bottom-bar and left sidebar
            Canvas {
                id: leftFillet
                x: 0
                y: 0
                width: 12
                height: 12

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, 12);
                    ctx.lineTo(12, 12);
                    ctx.arc(12, 0, 12, Math.PI / 2, Math.PI, false);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Bottom-right corner fillet connecting bottom-bar and right sidebar
            Canvas {
                id: rightFillet
                x: bottomBarWindow.width - 12
                y: 0
                width: 12
                height: 12

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(12, 0);
                    ctx.lineTo(12, 12);
                    ctx.lineTo(0, 12);
                    ctx.arc(0, 0, 12, Math.PI / 2, 0, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
}
