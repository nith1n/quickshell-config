// MusicMenu.qml
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import "../helpers"

PopupWindow {
    id: root

    property var player: null

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: 320
    implicitHeight: menuColumn.implicitHeight + 28
    visible: false
    color: "transparent"
    grabFocus: true

    // Refresh position every second when menu is open and playing
    property real currentPosition: player ? player.position : 0
    readonly property bool hasTimeline: (player?.lengthSupported ?? false) && (player?.length ?? 0) > 0
    readonly property real progressRatio: {
        if (!player || !player.length || player.length <= 0) return 0;
        return Math.max(0, Math.min(1, currentPosition / player.length));
    }

    Timer {
        interval: 1000
        running: root.visible && (root.player?.isPlaying ?? false)
        repeat: true
        onTriggered: {
            if (root.player) {
                root.currentPosition = root.player.position;
            }
        }
    }

    onVisibleChanged: {
        if (visible && root.player) {
            root.currentPosition = root.player.position;
        }
    }

    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onPositionChanged() {
            if (root.player) {
                root.currentPosition = root.player.position;
            }
        }
    }

    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds < 0) return "00:00";
        const totalSecs = Math.floor(seconds);
        const mins = Math.floor(totalSecs / 60);
        const secs = totalSecs % 60;
        const mStr = mins < 10 ? "0" + mins : mins.toString();
        const sStr = secs < 10 ? "0" + secs : secs.toString();
        return mStr + ":" + sStr;
    }

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
            anchors.margins: 14
            spacing: 14

            // -----------------------------------------------------------------
            // Header / Player Switcher (when multiple players are running)
            // -----------------------------------------------------------------
            Row {
                width: parent.width
                spacing: 8
                visible: Mpris.players.values.length > 1

                Repeater {
                    model: Mpris.players.values

                    Rectangle {
                        required property var modelData
                        width: chipText.implicitWidth + 16
                        height: 22
                        radius: 11
                        color: modelData === root.player ? Qt.alpha(Theme.accent, 0.2) : Qt.alpha(Theme.text, 0.06)
                        border.width: modelData === root.player ? 1 : 0
                        border.color: Theme.accent

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData.identity || "Player"
                            color: modelData === root.player ? Theme.accent : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 0.9
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.player = modelData;
                                root.currentPosition = modelData.position;
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // Main Track Info & Album Art
            // -----------------------------------------------------------------
            Row {
                width: parent.width
                spacing: 12

                // Album Art with rounded corners
                Item {
                    width: 72
                    height: 72
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: artMask
                        anchors.fill: parent
                        radius: 10
                        visible: false
                    }

                    Rectangle {
                        id: artPlaceholder
                        anchors.fill: parent
                        radius: 10
                        color: Qt.alpha(Theme.text, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "󰎆"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 30
                            color: Theme.textMuted
                        }
                    }

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        asynchronous: true
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: albumArt
                        maskSource: artMask
                        visible: albumArt.status === Image.Ready
                    }
                }

                // Text Metadata
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 84
                    spacing: 4

                    Text {
                        width: parent.width
                        text: root.player?.trackTitle || "Unknown Title"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 1.15
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: root.player?.trackArtist || "Unknown Artist"
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        visible: (root.player?.trackAlbum ?? "").length > 0
                        text: root.player?.trackAlbum || ""
                        color: Qt.alpha(Theme.textMuted, 0.75)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 0.9
                        elide: Text.ElideRight
                    }
                }
            }

            // -----------------------------------------------------------------
            // Timeline / Seek Bar
            // -----------------------------------------------------------------
            Column {
                width: parent.width
                spacing: 5
                visible: root.hasTimeline

                Item {
                    width: parent.width
                    height: posText.implicitHeight

                    Text {
                        id: posText
                        anchors.left: parent.left
                        text: root.formatTime(root.currentPosition)
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 0.85
                        font.bold: true
                    }

                    Text {
                        anchors.right: parent.right
                        text: root.formatTime(root.player?.length ?? 0)
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 0.85
                        font.bold: true
                    }
                }

                Rectangle {
                    id: seekBg
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Qt.alpha(Theme.text, 0.1)

                    Rectangle {
                        id: seekFill
                        width: Math.min(parent.width, Math.max(0, parent.width * root.progressRatio))
                        height: parent.height
                        radius: 3
                        color: Theme.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (root.player && root.player.canSeek && root.player.length > 0) {
                                const targetX = Math.max(0, Math.min(seekBg.width, mouse.x));
                                const ratio = targetX / seekBg.width;
                                root.player.position = ratio * root.player.length;
                                root.currentPosition = root.player.position;
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // Controls (Previous, Play/Pause, Next)
            // -----------------------------------------------------------------
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                // Previous Track
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: prevMouse.containsMouse ? Theme.pillBgHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: (root.player?.canGoPrevious ?? false) ? Theme.text : Theme.textMuted
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: root.player?.canGoPrevious ?? false
                        onClicked: {
                            if (root.player) root.player.previous();
                        }
                    }
                }

                // Play / Pause Toggle
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.accent
                    opacity: playMouse.containsMouse ? 0.9 : 1.0

                    Behavior on opacity {
                        NumberAnimation { duration: 120 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (root.player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: Theme.barBg
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.player) root.player.togglePlaying();
                        }
                    }
                }

                // Next Track
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: nextMouse.containsMouse ? Theme.pillBgHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: (root.player?.canGoNext ?? false) ? Theme.text : Theme.textMuted
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: root.player?.canGoNext ?? false
                        onClicked: {
                            if (root.player) root.player.next();
                        }
                    }
                }
            }
        }
    }
}
