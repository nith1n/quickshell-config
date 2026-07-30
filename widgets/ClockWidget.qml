// ClockWidget.qml
import QtQuick
import Quickshell
import "../helpers"

Rectangle {
    id: clockPill
    width: clockRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    // Smooth hover transition
    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            id: icon
            source: "../icons/clock.svg"
            color: Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: clockText
            text: Time.time
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: clockPill.color = Theme.pillBgHover
        onExited: clockPill.color = Theme.pillBg
    }
}
