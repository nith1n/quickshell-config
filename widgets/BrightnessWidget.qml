// BrightnessWidget.qml
import QtQuick
import Quickshell
import Quickshell.Io
import "../helpers"

Rectangle {
    id: brightnessPill

    // Properties
    readonly property string maxValText: maxBrightnessFile.text() ? maxBrightnessFile.text().trim() : "100"
    readonly property string currValText: currentBrightnessFile.text() ? currentBrightnessFile.text().trim() : "100"
    readonly property int percent: getBrightnessPercent(currValText, maxValText)

    // Functions
    function getBrightnessPercent(curr, maxVal) {
        var c = parseInt(curr);
        var m = parseInt(maxVal);
        if (isNaN(c) || isNaN(m) || m === 0) return 100;
        return Math.round((c / m) * 100);
    }

    // Backend Helpers & Resources
    FileView {
        id: maxBrightnessFile
        path: "/sys/class/backlight/intel_backlight/max_brightness"
    }

    FileView {
        id: currentBrightnessFile
        path: "/sys/class/backlight/intel_backlight/brightness"
    }

    Timer {
        interval: 5000 // poll brightness every 5 seconds
        running: true
        repeat: true
        onTriggered: {
            maxBrightnessFile.reload()
            currentBrightnessFile.reload()
        }
    }

    // Monitor backlight changes instantly via udev
    Process {
        id: udevMonitor
        command: ["udevadm", "monitor", "--subsystem=backlight"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                currentBrightnessFile.reload()
            }
        }
    }

    // Processes to change brightness via brightnessctl
    Process {
        id: brightUpProc
        command: ["brightnessctl", "set", "5%+"]
        onExited: {
            currentBrightnessFile.reload()
        }
    }

    Process {
        id: brightDownProc
        command: ["bash", "-c", "curr=$(brightnessctl g); max=$(brightnessctl m); min=$((max * 5 / 100)); next=$((curr - max * 5 / 100)); if [ $next -lt $min ]; then next=$min; fi; brightnessctl s $next"]
        onExited: {
            currentBrightnessFile.reload()
        }
    }

    // Widget Dimensions & Styling
    width: brightnessRow.implicitWidth + Theme.pillPadding
    height: Theme.pillHeight
    radius: Theme.pillRadius
    color: Theme.pillBg

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    // Visual Layout
    Row {
        id: brightnessRow
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        SvgIcon {
            source: "../icons/sun.svg"
            color: Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: brightnessPill.percent + "%"
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
        
        property int scrollAccumulator: 0
        onWheel: (wheel) => {
            if ((wheel.angleDelta.y > 0 && scrollAccumulator < 0) || 
                (wheel.angleDelta.y < 0 && scrollAccumulator > 0)) {
                scrollAccumulator = 0;
            }
            scrollAccumulator += wheel.angleDelta.y;
            
            const threshold = 120; // standard scroll tick (increase for slower scroll)
            if (scrollAccumulator >= threshold) {
                brightUpProc.running = true;
                scrollAccumulator = 0;
            } else if (scrollAccumulator <= -threshold) {
                brightDownProc.running = true;
                scrollAccumulator = 0;
            }
        }

        onEntered: brightnessPill.color = Theme.pillBgHover
        onExited: brightnessPill.color = Theme.pillBg
    }
}
