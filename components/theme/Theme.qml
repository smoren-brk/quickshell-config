pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Catppuccin Mocha palette.
    readonly property color mochaRed: "#f38ba8"
    readonly property color mochaMauve: "#cba6f7"
    readonly property color mochaBlue: "#89b4fa"
    readonly property color mochaLavender: "#b4befe"
    readonly property color mochaText: "#cdd6f4"
    readonly property color mochaSubtext1: "#bac2de"
    readonly property color mochaSubtext0: "#a6adc8"
    readonly property color mochaOverlay1: "#7f849c"
    readonly property color mochaOverlay0: "#6c7086"
    readonly property color mochaSurface2: "#585b70"
    readonly property color mochaSurface1: "#45475a"
    readonly property color mochaSurface0: "#313244"
    readonly property color mochaBase: "#1e1e2e"
    readonly property color mochaMantle: "#181825"

    readonly property color menuBarBackgroundColor: Qt.alpha(mochaBase, backgroundOpacity)
    readonly property color menuBarTextColor: mochaText
    readonly property color menuBarMutedColor: mochaOverlay1
    readonly property color menuBarHoverColor: Qt.alpha(mochaSurface2, 0.35)
    readonly property color neutralSelectionColor: mochaText
    readonly property color neutralSelectionTextColor: mochaBase
    readonly property color menuBarSelectedColor: Qt.alpha(mochaSurface2, 0.6)
    readonly property color menuBarBorderColor: Qt.alpha(mochaOverlay0, 0.35)

    readonly property color spotlightBackgroundColor: menuBarBackgroundColor
    readonly property color spotlightBorderColor: Qt.alpha(mochaOverlay1, 0.5)
    readonly property color spotlightSelectionColor: Qt.alpha(mochaMauve, 0.3)
    readonly property color spotlightSecondaryTextColor: mochaSubtext0

    readonly property real backgroundOpacity: 0.5
    readonly property color shellBackgroundColor: Qt.alpha(mochaMantle, backgroundOpacity)
    readonly property color selectedSurfaceColor: Qt.alpha(mochaSurface1, backgroundOpacity)
    readonly property color primaryTextColor: mochaText
    readonly property color mutedTextColor: mochaOverlay1
    readonly property color accentHoverColor: mochaLavender
    readonly property color accentTextColor: mochaBase
    readonly property color panelSurfaceColor: Qt.alpha(mochaSurface0, backgroundOpacity)
    readonly property color controlCenterCardColor: panelSurfaceColor
    readonly property color windowSurfaceColor: Qt.alpha(panelSurfaceColor, backgroundOpacity)
    readonly property color notificationCardColor: Qt.alpha(mochaSurface0, 0.7)
    readonly property color notificationIconColor: Qt.alpha(mochaBlue, 0.2)
    readonly property color notificationBorderColor: Qt.alpha(mochaOverlay1, 0.4)
    readonly property color notificationLabelColor: mochaSubtext1
    readonly property color secondaryTextColor: mochaSubtext0
    readonly property color surfaceBorderColor: mochaSurface2
    readonly property color accentColor: mochaMauve
    readonly property color dangerColor: mochaRed
}
