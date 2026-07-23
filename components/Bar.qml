// Bar.qml
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../widgets"
import "../helpers"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: topBarWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 48 // 36px bar + 12px corner radius
            exclusiveZone: 36  // Reserve 36px space at the top of the screen
            color: "transparent"

            // Define the clickthrough mask region
            mask: Region {
                regions: [
                    Region {
                        x: 0
                        y: 0
                        width: topBarWindow.width
                        height: 36
                    },
                    Region {
                        // Left corner fillet (aligned with right edge of 8px sidebar)
                        x: 8
                        y: 36
                        width: 12
                        height: 12
                    },
                    Region {
                        // Right corner fillet (aligned with left edge of 8px sidebar)
                        x: topBarWindow.width - 20
                        y: 36
                        width: 12
                        height: 12
                    }
                ]
            }

            // Solid background for the top bar (dark theme)
            Rectangle {
                id: barBackground
                x: 0
                y: 0
                width: topBarWindow.width
                height: 36
                color: Theme.barBg
            }

            // Left corner fillet connecting top-bar and left sidebar
            Canvas {
                id: leftFillet
                x: 8
                y: 36
                width: 12
                height: 12

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, 12);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(12, 0);
                    ctx.arc(12, 12, 12, -Math.PI / 2, Math.PI, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Right corner fillet connecting top-bar and right sidebar
            Canvas {
                id: rightFillet
                x: topBarWindow.width - 20
                y: 36
                width: 12
                height: 12

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(12, 0);
                    ctx.lineTo(12, 12);
                    ctx.arc(0, 12, 12, 0, -Math.PI / 2, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: barBackground.verticalCenter
                spacing: 15

                Workspace {}

                ActiveTitleWidget {}
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: barBackground.verticalCenter
                spacing: 5

                SoundWidget {}
                BrightnessWidget {}
                WifiWidget {}
                BluetoothWidget {}
                MemoryWidget {}
                BatteryWidget {}
                ClockWidget {}
            }
        }
    }
}
