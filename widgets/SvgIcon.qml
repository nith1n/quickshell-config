// SvgIcon.qml
import QtQuick
import Qt5Compat.GraphicalEffects
import "../helpers"

Item {
    id: root
    property alias source: img.source
    property color color: "white"
    property real size: Theme.iconSize

    width: size
    height: size

    Image {
        id: img
        anchors.fill: parent
        sourceSize: Qt.size(parent.width, parent.height)
        visible: false
        smooth: true
        antialiasing: true
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: root.color
        visible: img.status === Image.Ready
    }
}
