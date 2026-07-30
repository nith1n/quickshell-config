// SoundWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../helpers"

Rectangle {
    id: soundPill

    // Event-driven Pipewire properties
    property var sink: Pipewire.defaultAudioSink
    property bool isMuted: sink?.audio?.muted ?? false
    property int volume: Math.round((sink?.audio?.volume ?? 0) * 100)

    function getVolumeIcon(vol, muted) {
        if (muted) return "../icons/volume-x.svg";
        if (vol >= 50) return "../icons/volume-2.svg";
        return "../icons/volume-1.svg";
    }

    // Adjustment processes
    Process {
        id: volUpProc
        command: ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+"]
    }

    Process {
        id: volDownProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }

    // Widget Dimensions & Styling
    width: soundRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: soundRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            source: soundPill.getVolumeIcon(soundPill.volume, soundPill.isMuted)
            color: soundPill.isMuted ? Theme.danger : Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: soundPill.isMuted ? "Mute" : soundPill.volume + "%"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Interactivity
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: muteProc.running = true
        
        property int scrollAccumulator: 0
        onWheel: (wheel) => {
            if ((wheel.angleDelta.y > 0 && scrollAccumulator < 0) || 
                (wheel.angleDelta.y < 0 && scrollAccumulator > 0)) {
                scrollAccumulator = 0;
            }
            scrollAccumulator += wheel.angleDelta.y;
            
            const threshold = 120; // standard scroll tick (increase for slower scroll)
            if (scrollAccumulator >= threshold) {
                volUpProc.running = true;
                scrollAccumulator = 0;
            } else if (scrollAccumulator <= -threshold) {
                volDownProc.running = true;
                scrollAccumulator = 0;
            }
        }

        onEntered: soundPill.color = Theme.pillBgHover
        onExited: soundPill.color = Theme.pillBg
    }
}
