pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Tokyo Night (night) palette. Quickshell has no built-in theme loader.
    readonly property color nightRed: "#f7768e"
    readonly property color nightGreen: "#73daca"
    readonly property color nightBlue: "#7aa2f7"
    readonly property color nightText: "#c0caf5"
    readonly property color nightSubtext1: "#a9b1d6"
    readonly property color nightSubtext0: "#9aa5ce"
    readonly property color nightOverlay1: "#565f89"
    readonly property color nightOverlay0: "#565f89"
    readonly property color nightSurface2: "#414868"
    readonly property color nightSurface1: "#292e42"
    readonly property color nightSurface0: "#24283b"
    readonly property color nightBase: "#1a1b26"
    readonly property color nightMantle: "#16161e"

    readonly property color menuBarBackgroundColor: Qt.alpha(nightBase, backgroundOpacity)
    readonly property color menuBarTextColor: nightText
    readonly property color menuBarMutedColor: nightOverlay1
    readonly property color menuBarHoverColor: Qt.alpha(nightSurface2, 0.35)
    readonly property color neutralSelectionColor: accentColor
    readonly property color neutralSelectionTextColor: nightBase
    readonly property color menuBarSelectedColor: Qt.alpha(accentColor, 0.25)
    readonly property color menuBarBorderColor: Qt.alpha(nightOverlay0, 0.35)

    readonly property color spotlightBackgroundColor: menuBarBackgroundColor
    readonly property color spotlightBorderColor: Qt.alpha(nightOverlay1, 0.5)
    readonly property color spotlightSelectionColor: Qt.alpha(accentColor, 0.3)
    readonly property color spotlightSecondaryTextColor: nightSubtext0

    readonly property real backgroundOpacity: 0.5
    readonly property color shellBackgroundColor: Qt.alpha(nightMantle, backgroundOpacity)
    readonly property color selectedSurfaceColor: Qt.alpha(nightSurface1, backgroundOpacity)
    readonly property color primaryTextColor: nightText
    readonly property color mutedTextColor: nightOverlay1
    readonly property color accentHoverColor: accentColor
    readonly property color accentTextColor: nightBase
    readonly property color panelSurfaceColor: Qt.alpha(nightSurface0, backgroundOpacity)
    readonly property color controlCenterCardColor: panelSurfaceColor
    readonly property color windowSurfaceColor: Qt.alpha(panelSurfaceColor, backgroundOpacity)
    readonly property color notificationCardColor: Qt.alpha(nightSurface0, 0.7)
    readonly property color notificationIconColor: Qt.alpha(accentColor, 0.2)
    readonly property color notificationBorderColor: Qt.alpha(nightOverlay1, 0.4)
    readonly property color notificationLabelColor: nightSubtext1
    readonly property color secondaryTextColor: nightSubtext0
    readonly property color surfaceBorderColor: nightSurface2
    readonly property color accentColor: nightBlue
    readonly property color dangerColor: nightRed
}
