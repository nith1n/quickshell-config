// SoundWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: soundPill

    // Properties
    property int volume: 100
    property bool isMuted: false

    // Functions
    function parseVolume(text) {
        if (!text) return;
        var s = text.trim();
        // Format is "Volume: 1.00" or "Volume: 0.35 [MUTED]"
        var parts = s.split(" ");
        if (parts.length >= 2) {
            var volVal = parseFloat(parts[1]);
            if (!isNaN(volVal)) {
                soundPill.volume = Math.round(volVal * 100);
            }
        }
        soundPill.isMuted = s.includes("[MUTED]");
    }

    function getVolumeIcon(vol, muted) {
        if (muted) return "../icons/volume-x.svg";
        if (vol >= 50) return "../icons/volume-2.svg";
        return "../icons/volume-1.svg";
    }

    // Backend Helpers & Resources
    Process {
        id: volGetProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: soundPill.parseVolume(this.text)
        }
    }

    // Persistent process listening to volume changes instantly via PulseAudio/PipeWire events
    Process {
        id: pactlSubscribe
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("change") && line.includes("sink")) {
                    volGetProc.running = true
                }
            }
        }
    }

    // Safety fallback timer (every 5 seconds)
    Timer {
        id: fallbackTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: volGetProc.running = true
    }

    // Processes for adjustments (limit to 150% via -l 1.5)
    Process {
        id: volUpProc
        command: ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+"]
        onExited: volGetProc.running = true
    }

    Process {
        id: volDownProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
        onExited: volGetProc.running = true
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: volGetProc.running = true
    }

    // Widget Dimensions & Styling
    width: soundRow.implicitWidth + 28
    height: 22
    radius: 11
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: soundRow
        anchors.centerIn: parent
        spacing: 6

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
