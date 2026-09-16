// MusicWidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../helpers"

Rectangle {
    id: musicPill

    // -------------------------------------------------------------------------
    // Player Selection & State
    // -------------------------------------------------------------------------

    property var player: null

    function updatePlayer() {
        const list = Mpris.players.values;
        if (!list || list.length === 0) {
            musicPill.player = null;
            return;
        }

        // If current player is still valid and playing, keep it
        if (musicPill.player && musicPill.player.isPlaying) {
            return;
        }

        // 1. Find any currently playing player
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying) {
                musicPill.player = list[i];
                return;
            }
        }

        // 2. Find any player with a track title loaded
        for (let i = 0; i < list.length; i++) {
            if (list[i].trackTitle && list[i].trackTitle.length > 0) {
                musicPill.player = list[i];
                return;
            }
        }

        // 3. Fallback to first player
        musicPill.player = list[0];
    }

    Component.onCompleted: updatePlayer()

    Connections {
        target: Mpris.players
        function onValuesChanged() {
            musicPill.updatePlayer();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: musicPill.updatePlayer()
    }

    readonly property string trackText: {
        if (!player) return "";
        const title = (player.trackTitle || "").trim();
        const artist = (player.trackArtist || "").trim();
        if (artist.length > 0 && title.length > 0) {
            return artist + " - " + title;
        }
        return title || artist || "Media";
    }

    // Auto-hide when no player exists or nothing has been loaded
    visible: player !== null && ((player.trackTitle && player.trackTitle.length > 0) || player.isPlaying)

    // -------------------------------------------------------------------------
    // Widget Dimensions & Styling
    // -------------------------------------------------------------------------

    width: visible ? (musicRow.implicitWidth + Theme.pillPadding) : 0
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: pillMouse.containsMouse ? Theme.pillBgHover : Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // -------------------------------------------------------------------------
    // Visual Layout
    // -------------------------------------------------------------------------

    Row {
        id: musicRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        Text {
            text: (musicPill.player?.isPlaying ?? false) ? "󰎆" : "󰏤"
            color: (musicPill.player?.isPlaying ?? false) ? Theme.accent : Theme.textMuted
            font.family: "Symbols Nerd Font"
            font.pixelSize: 15
            rightPadding: 4
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: titleLabel
            text: musicPill.trackText
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 170)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // -------------------------------------------------------------------------
    // Interactivity
    // -------------------------------------------------------------------------

    MouseArea {
        id: pillMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                musicPopup.visible = !musicPopup.visible;
            } else if (mouse.button === Qt.MiddleButton) {
                if (musicPill.player) {
                    musicPill.player.togglePlaying();
                }
            } else if (mouse.button === Qt.RightButton) {
                if (musicPill.player) {
                    musicPill.player.next();
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Music Details Popup
    // -------------------------------------------------------------------------

    MusicMenu {
        id: musicPopup
        anchor.item: musicPill
        player: musicPill.player
    }
}
