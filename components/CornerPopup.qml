// CornerPopup.qml
import Quickshell
import QtQuick
import "../helpers"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: popupWindow
            required property var modelData
            screen: modelData

            anchors {
                bottom: true
                right: true
            }

            // Tell the window to ignore exclusive zones so it can extend to the very screen edges
            exclusionMode: ExclusionMode.Ignore

            // Window bounds that contain the fully expanded popup plus margins and fillets
            implicitWidth: 200
            implicitHeight: 120
            color: "transparent"

            // Dynamic mask region to cover the trigger area, popup container, and both fillets
            mask: Region {
                Region {
                    x: popupWindow.width - Math.max(triggerArea.width, container.width + Theme.rightSidebarWidth + Theme.popupRadius)
                    y: popupWindow.height - Math.max(triggerArea.height, container.height + Theme.bottomBarHeight + Theme.popupRadius)
                    width: Math.max(triggerArea.width, container.width + Theme.rightSidebarWidth + Theme.popupRadius)
                    height: Math.max(triggerArea.height, container.height + Theme.bottomBarHeight + Theme.popupRadius)
                }
            }

            // Invisible hover trigger area in the absolute bottom-right corner of the screen
            MouseArea {
                id: triggerArea
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: active ? 180 : 16
                height: active ? 100 : 16
                hoverEnabled: true

                property bool active: false

                onEntered: active = true
                onExited: active = false
            }

            // Bottom-left corner fillet (slides horizontally with the popup)
            Canvas {
                id: bottomLeftFillet
                x: container.x - Theme.popupRadius
                y: popupWindow.height - Theme.bottomBarHeight - Theme.popupRadius
                width: Theme.popupRadius
                height: Theme.popupRadius
                
                opacity: triggerArea.active ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(Theme.popupRadius, 0);
                    ctx.lineTo(Theme.popupRadius, Theme.popupRadius);
                    ctx.lineTo(0, Theme.popupRadius);
                    ctx.arc(0, 0, Theme.popupRadius, Math.PI / 2, 0, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Top-right corner fillet (slides vertically with the popup)
            Canvas {
                id: topRightFillet
                x: popupWindow.width - Theme.rightSidebarWidth - Theme.popupRadius
                y: container.y - Theme.popupRadius
                width: Theme.popupRadius
                height: Theme.popupRadius
                
                opacity: triggerArea.active ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = Theme.barBg;
                    ctx.beginPath();
                    ctx.moveTo(Theme.popupRadius, 0);
                    ctx.lineTo(Theme.popupRadius, Theme.popupRadius);
                    ctx.lineTo(0, Theme.popupRadius);
                    ctx.arc(0, 0, Theme.popupRadius, Math.PI / 2, 0, true);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            // Clipping Container to hide the bottom and right rounded corners of the popup
            Item {
                id: container
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                
                // Dynamic offsets to align perfectly with the border lines based on sidebar and bottom bar dimensions
                anchors.rightMargin: Theme.rightSidebarWidth
                anchors.bottomMargin: Theme.bottomBarHeight
                
                // Dynamic dimensions driven by the trigger state
                width: triggerArea.active ? 160 : 0
                height: triggerArea.active ? 80 : 0
                clip: true

                // Smooth expansion animations
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                Behavior on height {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                // Inner Rectangle that draws the solid background
                Rectangle {
                    id: popupRect
                    x: 0
                    y: 0
                    // Overflows the container to push bottom and right rounded corners outside the clipped area
                    width: parent.width + 20
                    height: parent.height + 20

                    // Rounded top-left corner
                    radius: Theme.popupRadius
                    color: Theme.barBg // Matches the bar background color exactly
                }

                // Info Text Content (Centered relative to the visible container area)
                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    // Smoothly fade in content as the container expands
                    opacity: triggerArea.active ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    Text {
                        id: timeText
                        text: Time.formattedTime
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 1.8
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id: dateText
                        text: Time.formattedDate
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 1.1
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
