// SoundWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../helpers"

Rectangle {
    id: soundPill

    // -------------------------------------------------------------------------
    // PipeWire Properties
    // -------------------------------------------------------------------------

    property var sink: Pipewire.defaultAudioSink
    property bool isMuted: sink?.audio?.muted ?? false
    property int volume: Math.round((sink?.audio?.volume ?? 0) * 100)

    PwObjectTracker {
        objects: soundPill.sink ? [soundPill.sink] : []
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    function getNodeIcon(node) {
        if (!node) return "󰓃";
        const desc = (node.description || node.nickname || node.name || "").toLowerCase();
        const raw = (node.name || "").toLowerCase();

        if (desc.indexOf("headphone") !== -1 || desc.indexOf("buds") !== -1 ||
            desc.indexOf("headset") !== -1 || desc.indexOf("ear") !== -1 ||
            raw.indexOf("headphones") !== -1) {
            return "󰋋";
        }
        if (desc.indexOf("bluetooth") !== -1 || raw.indexOf("bluez") !== -1) {
            return "󰂯";
        }
        if (desc.indexOf("hdmi") !== -1 || desc.indexOf("displayport") !== -1) {
            return "󰍹";
        }
        return "󰓃";
    }

    function getActiveDeviceIcon() {
        if (!sink) return "󰓃";
        if (sink.name && sink.name.indexOf("HiFi__Headphones__sink") !== -1) return "󰋋";
        if (sink.name && sink.name.indexOf("HiFi__Speaker__sink") !== -1) return "󰓃";
        return getNodeIcon(sink);
    }

    // -------------------------------------------------------------------------
    // Volume Processes
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // Widget Dimensions & Styling
    // -------------------------------------------------------------------------

    width: soundRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: soundPillMouse.containsMouse ? Theme.pillBgHover : Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Row {
        id: soundRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        Text {
            text: soundPill.getActiveDeviceIcon()
            color: soundPill.isMuted ? Theme.danger : Theme.accent
            font.family: "Symbols Nerd Font"
            font.pixelSize: 15
            rightPadding: 4
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

    MouseArea {
        id: soundPillMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                audioMenu.visible = !audioMenu.visible;
            } else if (mouse.button === Qt.RightButton) {
                muteProc.running = true;
            }
        }

        property int scrollAccumulator: 0
        onWheel: (wheel) => {
            if ((wheel.angleDelta.y > 0 && scrollAccumulator < 0) ||
                (wheel.angleDelta.y < 0 && scrollAccumulator > 0)) {
                scrollAccumulator = 0;
            }
            scrollAccumulator += wheel.angleDelta.y;

            const threshold = 120;
            if (scrollAccumulator >= threshold) {
                volUpProc.running = true;
                scrollAccumulator = 0;
            } else if (scrollAccumulator <= -threshold) {
                volDownProc.running = true;
                scrollAccumulator = 0;
            }
        }
    }

    // -------------------------------------------------------------------------
    // Audio Output Menu Popup
    // -------------------------------------------------------------------------

    SoundMenu {
        id: audioMenu
        anchor.item: soundPill
    }
}