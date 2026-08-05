// Theme.qml
pragma Singleton

import QtQuick
import "../generated"

QtObject {
    readonly property string fontFamily: "JetBrains Mono"

    // Active theme selection: "dark", "light", or "matugen"
    property string activeTheme: "matugen"

    // Multi-Theme Color Palettes
    readonly property var themes: ({
        // Matugen Dynamic Theme (from wallpaper)
        "matugen": {
            barBg: Colors.background,
            pillBg: Colors.surfaceContainer,
            pillBgHover: Colors.surfaceContainerHigh,
            accent: Colors.primary,
            text: Colors.on_surface,
            textMuted: Colors.outline,
            success: Colors.secondary,
            danger: Colors.error
        },
        // Miles Morales Dark Theme
        "dark": {
            barBg: "#07070a",          // Matte pitch-black background
            pillBg: "#12131a",         // Deep charcoal suit-mesh container
            pillBgHover: "#1d1f2b",    // Light charcoal hover highlight
            accent: "#ec1d23",         // Vibrant neon spray crimson red
            text: "#ffffff",           // Spider web pure white
            textMuted: "#62667d",      // Graffiti shadow muted blue-gray
            success: "#00f5c6",        // Electric neon teal
            danger: "#ff1744"          // Warning neon red
        },
        // Gwen Stacy Light Theme (Ghost-Spider Across the Spider-Verse)
        "light": {
            barBg: "#eef1f6",          // Clean Ghost-Spider off-white background
            pillBg: "#ffffff",         // Pure white suit container
            pillBgHover: "#e0e5ef",    // Soft cyan-tinted hover highlight
            accent: "#e60067",         // Vibrant Ghost-Spider neon magenta-pink
            text: "#0f172a",           // Midnight slate high-contrast text
            textMuted: "#64748b",      // Soft slate gray
            success: "#00c8b3",        // Neon cyan teal (Gwen ballet accent)
            danger: "#dc2626"          // Warning crimson red
        }
    })

    // Active palette resolver (with fallback to matugen)
    readonly property var palette: themes[activeTheme] || themes["matugen"]

    // Dynamic Color Tokens
    readonly property color barBg: palette.barBg
    readonly property color pillBg: palette.pillBg
    readonly property color pillBgHover: palette.pillBgHover
    readonly property color accent: palette.accent
    readonly property color text: palette.text
    readonly property color textMuted: palette.textMuted
    readonly property color success: palette.success
    readonly property color danger: palette.danger

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
