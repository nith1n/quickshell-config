// SoundMenu.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../helpers"

PopupWindow {
    id: root

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: 300
    implicitHeight: audioMenuColumn.implicitHeight + 28
    visible: false
    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (visible && !checkHeadphonesProc.running)
            checkHeadphonesProc.running = true;
    }

    // -------------------------------------------------------------------------
    // PipeWire & Device State
    // -------------------------------------------------------------------------

    property var sink: Pipewire.defaultAudioSink

    // Dell Latitude 3420 SOF HDA card & profiles
    property string cardName: "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
    property string speakerProfile: "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
    property string headphonesProfile: "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Headset, Mic1)"

    property bool speakerActive: sink?.name !== undefined && sink.name.indexOf("HiFi__Speaker__sink") !== -1
    property bool headphonesActive: sink?.name !== undefined && sink.name.indexOf("HiFi__Headphones__sink") !== -1
    property bool headphonesConnected: false

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    function isLaptopOutput(node) {
        if (!node || !node.name) return false;
        return node.name.indexOf(root.cardName) !== -1 ||
               node.name.indexOf("skl_hda_dsp_generic") !== -1;
    }

    function isDynamicSink(node) {
        if (!node || !node.name) return false;
        return node.isSink === true &&
               node.isStream !== true &&
               !root.isLaptopOutput(node);
    }

    readonly property bool hasDynamicSinks: {
        const list = Pipewire.nodes.values;
        if (!list) return false;
        for (let i = 0; i < list.length; i++) {
            if (root.isDynamicSink(list[i])) return true;
        }
        return false;
    }

    function getNodeName(node) {
        if (!node) return "Unknown";
        return node.description || node.nickname || node.name || "Unknown";
    }

    function getNodeIcon(node) {
        if (!node) return "󰓃";
        const desc = getNodeName(node).toLowerCase();
        const raw = (node.name || "").toLowerCase();

        if (desc.indexOf("headphone") !== -1 || desc.indexOf("buds") !== -1 ||
            desc.indexOf("headset") !== -1 || desc.indexOf("ear") !== -1) {
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

    function selectSink(node) {
        if (!node) return;
        Pipewire.preferredDefaultAudioSink = node;
        root.visible = false;
    }

    function selectProfile(profile, sinkPattern) {
        if (switchProfileProc.running) {
            switchProfileProc.running = false;
        }

        switchProfileProc.command = [
            "sh", "-c",
            "pactl set-card-profile '" + cardName + "' '" + profile + "' && " +
            "for i in $(seq 1 30); do " +
            "sink=$(pactl list short sinks | awk '$2 ~ /" + sinkPattern + "/ {print $2; exit}'); " +
            "if [ -n \"$sink\" ]; then pactl set-default-sink \"$sink\"; exit 0; fi; " +
            "sleep 0.1; done"
        ];
        switchProfileProc.running = true;
        root.visible = false;
    }

    // -------------------------------------------------------------------------
    // Backend Processes
    // -------------------------------------------------------------------------

    Process {
        id: switchProfileProc
    }

    Process {
        id: checkHeadphonesProc
        command: ["sh", "-c", "pactl list cards | grep -E '^\\s*\\[Out\\] Headphones:' | grep -qv 'not available'"]
        running: true
        onExited: (code) => {
            root.headphonesConnected = (code === 0);
        }
    }

    Timer {
        interval: 2500
        running: root.visible
        repeat: true
        onTriggered: {
            if (!checkHeadphonesProc.running)
                checkHeadphonesProc.running = true;
        }
    }

    // -------------------------------------------------------------------------
    // Menu Container
    // -------------------------------------------------------------------------

    Rectangle {
        id: audioMenu
        anchors.fill: parent
        anchors.topMargin: 8
        radius: 14
        color: Theme.pillBg
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.08)

        Column {
            id: audioMenuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 3

            Text {
                text: "Output"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                leftPadding: 8
                topPadding: 4
                bottomPadding: 5
            }

            AudioDeviceItem {
                icon: "󰓃"
                title: "Speaker"
                isActive: root.speakerActive
                onClicked: root.selectProfile(root.speakerProfile, "\\.HiFi__Speaker__sink$")
            }

            AudioDeviceItem {
                visible: root.headphonesConnected || root.headphonesActive
                height: visible ? 42 : 0
                icon: "󰋋"
                title: "Headphones"
                isActive: root.headphonesActive
                onClicked: root.selectProfile(root.headphonesProfile, "\\.HiFi__Headphones__sink$")
            }

            Rectangle {
                width: parent.width - 12
                height: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.alpha(Theme.text, 0.08)
                visible: root.hasDynamicSinks
            }

            Repeater {
                model: Pipewire.nodes

                delegate: AudioDeviceItem {
                    required property var modelData
                    property var node: modelData
                    property bool isDynamic: root.isDynamicSink(node)

                    visible: isDynamic
                    height: visible ? 42 : 0
                    icon: root.getNodeIcon(node)
                    title: root.getNodeName(node)
                    isActive: isDynamic && root.sink?.name === node?.name

                    PwObjectTracker {
                        objects: isDynamic && node ? [node] : []
                    }

                    onClicked: root.selectSink(node)
                }
            }
        }
    }
}
