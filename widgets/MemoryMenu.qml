// MemoryMenu.qml
import QtQuick
import Quickshell
import "../helpers"

PopupWindow {
    id: root

    property var memData: ({
        ram: 0,
        ramUsedGB: "0.0",
        ramTotalGB: "0.0",
        ramRatio: 0,
        swap: 0,
        swapUsedGB: "0.0",
        swapTotalGB: "0.0",
        swapRatio: 0
    })

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: 260
    implicitHeight: menuColumn.implicitHeight + 28
    visible: false
    color: "transparent"
    grabFocus: true

    Rectangle {
        id: menuBackground
        anchors.fill: parent
        anchors.topMargin: 8
        radius: 14
        color: Theme.pillBg
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.08)

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 12

            Text {
                text: "Memory Details"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
            }

            // -----------------------------------------------------------------
            // RAM Section
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: 6

                Item {
                    width: parent.width
                    height: ramLabel.implicitHeight

                    Text {
                        id: ramLabel
                        anchors.left: parent.left
                        text: "RAM"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.memData.ramUsedGB + " / " + root.memData.ramTotalGB + " GB (" + root.memData.ram + "%)"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Qt.alpha(Theme.text, 0.1)

                    Rectangle {
                        width: Math.min(parent.width, Math.max(0, parent.width * root.memData.ramRatio))
                        height: parent.height
                        radius: 3
                        color: root.memData.ram > 85 ? Theme.danger : Theme.accent
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.alpha(Theme.text, 0.08)
            }

            // -----------------------------------------------------------------
            // Swap Section
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: 6

                Item {
                    width: parent.width
                    height: swapLabel.implicitHeight

                    Text {
                        id: swapLabel
                        anchors.left: parent.left
                        text: "Swap"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.memData.swapUsedGB + " / " + root.memData.swapTotalGB + " GB (" + root.memData.swap + "%)"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Qt.alpha(Theme.text, 0.1)

                    Rectangle {
                        width: Math.min(parent.width, Math.max(0, parent.width * root.memData.swapRatio))
                        height: parent.height
                        radius: 3
                        color: root.memData.swap > 80 ? Theme.danger : Theme.accent
                    }
                }
            }
        }
    }
}
