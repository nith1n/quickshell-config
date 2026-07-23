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
            Canvas {
                id: leftFillet
                x: 0
                y: 0
                width: Theme.filletRadius
                height: Theme.filletRadius

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(0, Theme.filletRadius);
                    ctx.lineTo(Theme.filletRadius, Theme.filletRadius);
                    ctx.arc(Theme.filletRadius, 0, Theme.filletRadius, Math.PI / 2, Math.PI, false);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Bottom-right corner fillet connecting bottom-bar and right sidebar
            Canvas {
                id: rightFillet
                x: bottomBarWindow.width - Theme.filletRadius
                y: 0
                width: Theme.filletRadius
                height: Theme.filletRadius

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(Theme.filletRadius, 0);
                    ctx.lineTo(Theme.filletRadius, Theme.filletRadius);
                    ctx.lineTo(0, Theme.filletRadius);
                    ctx.arc(0, 0, Theme.filletRadius, Math.PI / 2, 0, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
}
