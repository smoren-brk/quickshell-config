import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../../components"
import "../../components/theme"
import "../../components/state"
import "../../services"
import "../notifications"
import "../launcher"
import "../brightness"

PanelWindow {
    id: root
    required property var modelData
    property bool notificationsOpen: false
    property bool brightnessOpen: false
    property bool hoverVisible: false
    readonly property bool opened: LauncherState.visible && LauncherState.outputName === modelData.name
    property string displayedMode: "runner"
    readonly property bool switchingMode: opened && displayedMode !== LauncherState.mode
    readonly property bool dockWanted: hoverVisible || hover.hovered || LauncherState.barPinned || opened || expansion > 0 || notificationsOpen || brightnessOpen || tray.expanded
    readonly property bool popupOpen: notificationsOpen || brightnessOpen || tray.expanded
    property real reveal: dockWanted ? 1 : 0
    property real expansion: opened && reveal > 0.6 && !switchingMode ? 1 : 0
    readonly property real dockWidth: Math.min(modelData.width - 24, dockRow.width + 24)
    readonly property real runnerWidth: Math.min(modelData.width - 24, ShellMetrics.runnerWidth)
    property real contentHeight: launcher.desiredHeight

    screen: modelData
    visible: dockWanted || reveal > 0
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-bar"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region {
        x: Math.round(surface.x)
        y: Math.min(root.height - ShellMetrics.borderWidth - 1, Math.round(surface.y))
        width: Math.round(surface.width)
        // Keep a nonempty region at both ends of the reveal animation;
        // Niri otherwise falls back to blurring the whole window.
        height: Math.max(1, Math.round(surface.height))
        radius: Math.min(Math.round(surface.radius), Math.floor(height / 2))
    }
    // Only the surface and its route to the bottom edge receive pointer events.
    // Expanded modes additionally receive outside clicks to dismiss them.
    mask: Region {
        x: root.opened || root.popupOpen ? 0 : Math.round(surface.x)
        y: root.opened || root.popupOpen ? 0 : Math.min(root.height - 2, Math.round(surface.y))
        width: root.opened || root.popupOpen ? root.width : Math.round(surface.width)
        height: root.opened || root.popupOpen ? root.height : Math.max(2, root.height - Math.round(surface.y))
    }

    function focusSearch(): void {
        if (opened) launcher.focusTarget.forceActiveFocus();
    }
    function toggleBrightness(): void {
        notificationsOpen = false;
        tray.expanded = false;
        brightnessOpen = !brightnessOpen;
    }
    function syncMode(): void {
        if (opened) {
            notificationsOpen = false;
            brightnessOpen = false;
            tray.expanded = false;
            if (expansion === 0) displayedMode = LauncherState.mode;
            Qt.callLater(focusSearch);
        } else if (!hover.hovered) {
            hideTimer.restart();
        }
    }
    onOpenedChanged: Qt.callLater(syncMode)
    onExpansionChanged: {
        if (expansion === 0 && switchingMode) Qt.callLater(syncMode);
    }
    onSwitchingModeChanged: {
        if (switchingMode && expansion === 0) Qt.callLater(syncMode);
    }
    onDisplayedModeChanged: Qt.callLater(focusSearch)
    onRevealChanged: LauncherState.reportBarVisibility(screen.name, reveal > 0.01)
    Component.onDestruction: LauncherState.reportBarVisibility(modelData.name, false)
    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(focusSearch)

    Connections {
        target: LauncherState
        function onBarHideRequested() {
            root.hoverVisible = false;
            root.brightnessOpen = false;
            root.notificationsOpen = false;
            tray.expanded = false;
        }
    }
    Behavior on reveal { NumberAnimation { duration: ShellMetrics.revealDuration; easing.type: Easing.OutCubic } }
    Behavior on expansion {
        NumberAnimation { duration: root.opened && !root.switchingMode ? ShellMetrics.expandDuration : ShellMetrics.collapseDuration; easing.type: Easing.OutCubic }
    }
    Behavior on contentHeight {
        // Only search results resize an already expanded surface. A new mode
        // adopts its height before the morph, avoiding a rise-and-shrink bump.
        enabled: root.expansion === 1 && root.opened && !root.switchingMode
        NumberAnimation { duration: ShellMetrics.expandDuration; easing.type: Easing.OutCubic }
    }

    Timer {
        id: hideTimer
        interval: ShellMetrics.hideDelay
        onTriggered: if (!hover.hovered) root.hoverVisible = false
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    Binding {
        target: BrightnessService
        property: "active"
        value: true
        when: root.brightnessOpen
        restoreMode: Binding.RestoreBindingOrValue
    }

    // Unmap the large surface completely while hidden. An empty client blur
    // region can otherwise fall back to a compositor's whole-surface rule.
    PanelWindow {
        screen: root.screen
        visible: !root.dockWanted && root.reveal === 0
        color: "transparent"
        implicitWidth: root.dockWidth
        implicitHeight: 2
        anchors.bottom: true
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wisp-activation"
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hoverVisible = true
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: root.opened || root.popupOpen
        onClicked: {
            LauncherState.visible = false;
            root.brightnessOpen = false;
            root.notificationsOpen = false;
            tray.expanded = false;
        }
    }
    RectangularShadow {
        anchors.fill: surface
        radius: surface.radius
        blur: 16
        offset.y: 3
        color: "#30000000"
        opacity: root.reveal
        visible: surface.visible
    }
    AttachedSurface {
        id: surface
        x: (root.width - width) / 2
        y: root.height - ShellMetrics.borderWidth - height
        width: root.dockWidth + (root.runnerWidth - root.dockWidth) * root.expansion
        height: (ShellMetrics.dockHeight + (root.contentHeight - ShellMetrics.dockHeight) * root.expansion) * root.reveal
        radius: 8 + 4 * root.expansion
        visible: root.reveal > 0
        color: Theme.shellBackgroundColor
        // Track the surface and its children, including the route to the bottom edge.
        HoverHandler {
            id: hover
            margin: ShellMetrics.borderWidth + surface.radius
            onHoveredChanged: {
                if (hovered) {
                    hideTimer.stop();
                    root.hoverVisible = true;
                } else hideTimer.restart();
            }
        }
        // Consume clicks in the surface's padding, ahead of the outside target.
        MouseArea { anchors.fill: parent }
        Item {
            anchors.fill: parent
            anchors.margins: 1
            clip: true
            Row {
                id: dockRow
                anchors.centerIn: parent
                height: ShellMetrics.dockHeight
                spacing: 8
                opacity: Math.max(0, 1 - root.expansion / 0.38)
                visible: opacity > 0
                enabled: !root.opened

                DockButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Icons.search
                    label: "Applications"
                    onClicked: LauncherState.toggleForOutput(root.screen.name, "runner")
                }
                RunningApps {
                    id: runningApps
                    outputName: root.screen.name
                    anchors.verticalCenter: parent.verticalCenter
                    maximumWidth: Math.max(46, Math.min(360, root.width - 440 - workspaces.width - tray.width))
                    visible: groups.length > 0
                }
                Rectangle { width: 1; height: 24; anchors.verticalCenter: parent.verticalCenter; color: Theme.dividerColor }
                StatusBarWorkspaceSection {
                    id: workspaces
                    outputName: root.screen.name
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle { width: 1; height: 24; anchors.verticalCenter: parent.verticalCenter; color: Theme.dividerColor }
                SystemTraySection {
                    id: tray
                    barWindow: root
                    anchors.verticalCenter: parent.verticalCenter
                    onExpandedChanged: {
                        if (expanded) {
                            root.brightnessOpen = false;
                            root.notificationsOpen = false;
                        }
                    }
                }
                DockButton {
                    id: brightnessButton
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Icons.brightness
                    label: "Brightness"
                    active: root.brightnessOpen
                    onClicked: root.toggleBrightness()
                }
                DockButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Icons.notifications
                    label: "Notifications"
                    active: root.notificationsOpen || NotificationService.notificationCount > 0
                    onClicked: {
                        root.brightnessOpen = false;
                        tray.expanded = false;
                        root.notificationsOpen = !root.notificationsOpen;
                    }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 66
                    spacing: 3
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: Theme.primaryTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(clock.date, "ddd d MMM")
                        color: Theme.secondaryTextColor
                        font.family: Typography.bodyFontFamily
                        font.pixelSize: 10
                    }
                }
                DockButton {
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: Icons.power
                    label: "Power and session"
                    onClicked: LauncherState.toggleForOutput(root.screen.name, "power")
                }
            }
            ApplicationLauncher {
                id: launcher
                width: root.runnerWidth - 2
                height: root.contentHeight - 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                maximumHeight: Math.max(124, Math.min(560, root.height - 48))
                mode: root.displayedMode
                shown: root.opened && !root.switchingMode
                enabled: shown
                opacity: Math.max(0, (root.expansion - 0.4) / 0.6)
                visible: opacity > 0
                onVisibleChanged: if (visible) Qt.callLater(root.focusSearch)
                onCloseRequested: LauncherState.visible = false
            }
        }
    }
    PanelWindow {
        id: brightnessWindow
        property real reveal: root.brightnessOpen ? 1 : 0
        readonly property real fullHeight: Math.min(brightnessPanel.implicitHeight + 32, root.screen.height - 64)
        Behavior on reveal { NumberAnimation { duration: root.brightnessOpen ? ShellMetrics.expandDuration : ShellMetrics.collapseDuration; easing.type: Easing.OutCubic } }
        screen: root.screen
        visible: root.brightnessOpen || reveal > 0
        color: "transparent"
        implicitWidth: Math.min(400, root.screen.width - 2 * ShellMetrics.borderWidth)
        implicitHeight: Math.max(1, Math.round(fullHeight * reveal))
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: Math.round(root.height - surface.y)
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-brightness"
        WlrLayershell.keyboardFocus: root.brightnessOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        AttachedSurface {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            radius: 20
            Item {
                anchors.fill: parent
                clip: true
                BrightnessPanel {
                    id: brightnessPanel
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                    focus: root.brightnessOpen
                    Keys.onEscapePressed: root.brightnessOpen = false
                }
            }
        }
    }

    PanelWindow {
        id: historyWindow
        property real reveal: root.notificationsOpen ? 1 : 0
        readonly property real fullHeight: Math.min(600, root.screen.height - 64)
        Behavior on reveal { NumberAnimation { duration: root.notificationsOpen ? ShellMetrics.expandDuration : ShellMetrics.collapseDuration; easing.type: Easing.OutCubic } }
        screen: root.screen
        visible: root.notificationsOpen || reveal > 0
        color: "transparent"
        implicitWidth: Math.min(420, root.screen.width - 2 * ShellMetrics.borderWidth)
        implicitHeight: Math.max(1, Math.round(fullHeight * reveal))
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        margins.top: ShellMetrics.borderWidth
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-notification-history"
        WlrLayershell.keyboardFocus: root.notificationsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        AttachedSurface {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            attachedTop: true
            radius: 20
            Item {
                anchors.fill: parent
                clip: true
                NotificationPanel {
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                    height: historyWindow.fullHeight - 32
                    focus: root.notificationsOpen
                    Keys.onEscapePressed: root.notificationsOpen = false
                }
            }
        }
    }

    PanelWindow {
        screen: root.screen
        visible: NotificationService.popupNotificationCount > 0 && !root.notificationsOpen && historyWindow.reveal === 0
        color: "transparent"
        implicitWidth: Math.min(420, root.screen.width - 2 * ShellMetrics.borderWidth)
        implicitHeight: stack.desiredHeight
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        margins.top: ShellMetrics.borderWidth
        // Niri hides the top layer behind fullscreen windows on this output.
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qqq-notification-popups"

        AttachedSurface {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            attachedTop: true
            radius: 20

            NotificationStack {
                id: stack
                anchors.fill: parent
                maximumHeight: Math.max(1, root.screen.height - 64)
            }
        }
    }
}
