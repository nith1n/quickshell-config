// AudioDeviceItem.qml
import QtQuick
import "../helpers"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property bool isActive: false
    signal clicked()

    width: parent.width
    height: 42
    radius: 9

    color:
        isActive
            ? Qt.alpha(Theme.accent, 0.16)
            : itemMouse.containsMouse
                ? Qt.alpha(Theme.text, 0.07)
                : "transparent"

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Text {
        id: itemIcon
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        color: root.isActive ? Theme.accent : Theme.text
        font.family: "Symbols Nerd Font"
        font.pixelSize: 19
    }

    Text {
        id: itemCheck
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        visible: root.isActive
        text: "✓"
        color: Theme.accent
        font.pixelSize: Theme.fontSize
        font.bold: true
    }

    Text {
        anchors.left: itemIcon.right
        anchors.leftMargin: 12
        anchors.right: itemCheck.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
    }
}
