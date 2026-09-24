pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Neutral colors for the translucent menu bar.
    readonly property color menuBarBackgroundColor: Qt.alpha("#121214", backgroundOpacity)
    readonly property color menuBarTextColor: "#e8e8ea"
    readonly property color menuBarMutedColor: Qt.alpha(menuBarTextColor, 0.46)
    readonly property color menuBarHoverColor: Qt.alpha("white", 0.08)
    readonly property color neutralSelectionColor: "#d8d8dc"
    readonly property color neutralSelectionTextColor: "#121214"
    readonly property color menuBarSelectedColor: Qt.alpha("white", 0.14)
    readonly property color menuBarBorderColor: Qt.alpha("white", 0.07)

    readonly property color spotlightBackgroundColor: menuBarBackgroundColor
    readonly property color spotlightBorderColor: Qt.alpha("white", 0.15)
    readonly property color spotlightSelectionColor: "#2d5eb7"
    readonly property color spotlightSecondaryTextColor: "#aaaab0"

    readonly property real backgroundOpacity: 0.5
    readonly property color shellBackgroundColor: Qt.alpha("#111111", backgroundOpacity)
    readonly property color selectedSurfaceColor: Qt.alpha("#1a1a28", backgroundOpacity)
    readonly property color primaryTextColor: "#bdc6e3"
    readonly property color mutedTextColor: "#626679"
    readonly property color accentHoverColor: "#d4b984"
    readonly property color accentTextColor: "#0d0d16"
    readonly property color panelSurfaceColor: Qt.alpha("#1c1c1c", backgroundOpacity)
    readonly property color controlCenterCardColor: panelSurfaceColor
    readonly property color windowSurfaceColor: Qt.alpha(panelSurfaceColor, backgroundOpacity)
    readonly property color notificationCardColor: Qt.alpha("#292e40", 0.7)
    readonly property color notificationIconColor: Qt.alpha("#96a2c9", 0.2)
    readonly property color notificationBorderColor: Qt.alpha("white", 0.12)
    readonly property color notificationLabelColor: "#aab2cc"
    readonly property color secondaryTextColor: "#969eb7"
    readonly property color surfaceBorderColor: "#3d3d3d"
    readonly property color accentColor: "#dc926c"
    readonly property color dangerColor: "#e1849b"
}
