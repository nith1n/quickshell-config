// Theme.qml
pragma Singleton

import QtQuick

QtObject {
    readonly property string fontFamily: "JetBrains Mono"

    // Backgrounds (Miles Morales Dark Theme)
    readonly property color barBg: "#07070a"          // Matte pitch-black background
    readonly property color pillBg: "#12131a"         // Deep charcoal suit-mesh widget container
    readonly property color pillBgHover: "#1d1f2b"    // Light charcoal suit-mesh hover highlight

    // Accents & Texts
    readonly property color accent: "#ec1d23"         // Vibrant neon spray crimson red
    readonly property color text: "#ffffff"           // Spider web pure white
    readonly property color textMuted: "#62667d"      // Graffiti shadow muted blue-gray

    // Status colors
    readonly property color success: "#00f5c6"        // Electric neon teal (connected/charging)
    readonly property color danger: "#ff1744"         // Warning neon red

    // Sizes
    readonly property real fontSize: 10
    readonly property real iconSize: 18

    // Bar/Panel Dimensions
    readonly property real topBarHeight: 40
    readonly property real bottomBarHeight: 10
    readonly property real leftSidebarWidth: 10
    readonly property real rightSidebarWidth: 10

    // Corner Fillet Radii
    readonly property real filletRadius: 12
    readonly property real popupRadius: 4

    // Pill Dimensions
    readonly property real pillHeight: 27
    readonly property real pillRadius: 8
    readonly property real pillPadding: 20
    readonly property real pillSpacing: 3

    // Workspace Dimensions
    readonly property real wsSize: 20
    readonly property real wsRadius: 8
    readonly property real wsSpacing: 6

    // Bar Layout Spacing
    readonly property real widgetSpacing: 5
}
