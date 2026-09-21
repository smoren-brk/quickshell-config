pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Neutral colors for the translucent menu bar.
    readonly property color menuBarBackgroundColor: Qt.alpha("#171719", backgroundOpacity)
    readonly property color menuBarTextColor: "#f5f5f7"
    readonly property color menuBarMutedColor: Qt.alpha(menuBarTextColor, 0.46)
    readonly property color menuBarHoverColor: Qt.alpha("white", 0.10)
    readonly property color menuBarSelectedColor: Qt.alpha("white", 0.17)
    readonly property color menuBarBorderColor: Qt.alpha("white", 0.09)

    readonly property color spotlightBackgroundColor: menuBarBackgroundColor
    readonly property color spotlightBorderColor: Qt.alpha("white", 0.18)
    readonly property color spotlightSelectionColor: "#3268c8"
    readonly property color spotlightSecondaryTextColor: "#b8b8bd"

    readonly property real backgroundOpacity: 0.5
    readonly property color shellBackgroundColor: Qt.alpha("#161616", backgroundOpacity)
    readonly property color selectedSurfaceColor: Qt.alpha("#1e1e2e", backgroundOpacity)
    readonly property color primaryTextColor: "#cdd6f4"
    readonly property color mutedTextColor: "#6c7086"
    readonly property color accentHoverColor: "#e5c890"
    readonly property color accentTextColor: "#11111b"
    readonly property color panelSurfaceColor: Qt.alpha("#222222", backgroundOpacity)
    readonly property color controlCenterCardColor: panelSurfaceColor
    readonly property color windowSurfaceColor: Qt.alpha(panelSurfaceColor, backgroundOpacity)
    readonly property color secondaryTextColor: "#a6adc8"
    readonly property color surfaceBorderColor: "#454545"
    readonly property color accentColor: "#ef9f76"
    readonly property color dangerColor: "#f38ba8"
}
