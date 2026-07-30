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

            implicitHeight: Theme.topBarHeight + Theme.filletRadius
            exclusiveZone: Theme.topBarHeight
            color: "transparent"

            // Define the clickthrough mask region
            mask: Region {
                regions: [
                    Region {
                        x: 0
                        y: 0
                        width: topBarWindow.width
                        height: Theme.topBarHeight
                    },
                    Region {
                        // Left corner fillet (aligned with right edge of left sidebar)
                        x: Theme.leftSidebarWidth
                        y: Theme.topBarHeight
                        width: Theme.filletRadius
                        height: Theme.filletRadius
                    },
                    Region {
                        // Right corner fillet (aligned with left edge of right sidebar)
                        x: topBarWindow.width - Theme.rightSidebarWidth - Theme.filletRadius
                        y: Theme.topBarHeight
                        width: Theme.filletRadius
                        height: Theme.filletRadius
                    }
                ]
            }

            // Solid background for the top bar (dark theme)
            Rectangle {
                id: barBackground
                x: 0
                y: 0
                width: topBarWindow.width
                height: Theme.topBarHeight
                color: Theme.barBg
            }

            // Left corner fillet connecting top-bar and left sidebar
            Canvas {
                id: leftFillet
                x: Theme.leftSidebarWidth
                y: Theme.topBarHeight
                width: Theme.filletRadius
                height: Theme.filletRadius

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, Theme.filletRadius);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(Theme.filletRadius, 0);
                    ctx.arc(Theme.filletRadius, Theme.filletRadius, Theme.filletRadius, -Math.PI / 2, Math.PI, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Right corner fillet connecting top-bar and right sidebar
            Canvas {
                id: rightFillet
                x: topBarWindow.width - Theme.rightSidebarWidth - Theme.filletRadius
                y: Theme.topBarHeight
                width: Theme.filletRadius
                height: Theme.filletRadius

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(Theme.filletRadius, 0);
                    ctx.lineTo(Theme.filletRadius, Theme.filletRadius);
                    ctx.arc(0, Theme.filletRadius, Theme.filletRadius, 0, -Math.PI / 2, true);
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
                spacing: Theme.widgetSpacing

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
