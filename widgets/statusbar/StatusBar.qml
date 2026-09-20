import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/theme"
import "../../services"
import "../notifications"
import "../launcher"
import "../controlcenter"
import "../volume"
import "../../components/state"

PanelWindow {
    id: root

    required property var modelData

    property bool notificationsOpen: false
    readonly property bool controlCenterOpen: ControlCenterState.visible
        && ControlCenterState.outputName === root.screen.name

    onControlCenterOpenChanged: if (controlCenterOpen) notificationsOpen = false
    readonly property bool volumeOpen: VolumeService.visible && VolumeService.outputName === root.screen.name

    onVolumeOpenChanged: {
        if (volumeOpen) {
            notificationsOpen = false;
            LauncherState.visible = false;
        }
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    screen: modelData
    color: "transparent"
    implicitHeight: 30
    exclusiveZone: implicitHeight

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qqq-bar"
    BackgroundEffect.blurRegion: Region { item: barBackground }

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Theme.menuBarBackgroundColor

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: Theme.menuBarBorderColor
        }

        Row {
            id: leftSection
            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
            spacing: 10
            // Clip long workspace lists before they reach the status controls.
            width: Math.min(implicitWidth, Math.max(0, rightSection.x - x - 16))
            clip: true

            MenuBarButton {
                text: Icons.nixos
                fontSize: 19
                selected: LauncherState.visible && LauncherState.outputName === root.screen.name
                onClicked: {
                    root.notificationsOpen = false;
                    ControlCenterState.visible = false;
                    VolumeService.hide();
                    LauncherState.toggleForOutput(root.screen.name);
                }
            }

            StatusBarWorkspaceSection {
                outputName: root.screen.name
            }
        }

        Row {
            id: rightSection
            anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
            spacing: 3

            SystemTraySection {
                barWindow: root
            }

            MenuBarButton {
                selected: root.controlCenterOpen
                onClicked: ControlCenterState.toggleForOutput(root.screen.name)
                Accessible.role: Accessible.Button
                Accessible.name: "Control Centre"

                Item {
                    anchors.centerIn: parent
                    width: 18
                    height: 16
                    Repeater {
                        model: 2
                        Rectangle {
                            required property int index
                            y: index * 9
                            width: 18
                            height: 7
                            radius: 3.5
                            color: index === 0 ? Theme.menuBarTextColor : "transparent"
                            border.color: Theme.menuBarTextColor
                            Rectangle {
                                x: parent.index === 0 ? 2 : 11
                                y: 1.5
                                width: 4
                                height: 4
                                radius: 2
                                color: parent.index === 0 ? Theme.panelSurfaceColor : Theme.menuBarTextColor
                            }
                        }
                    }
                }
            }

            MenuBarButton {
                text: Icons.notifications
                selected: root.notificationsOpen
                onClicked: {
                    VolumeService.hide();
                    LauncherState.visible = false;
                    ControlCenterState.visible = false;
                    root.notificationsOpen = !root.notificationsOpen;
                }

                Rectangle {
                    anchors { top: parent.top; right: parent.right; topMargin: 4; rightMargin: 5 }
                    width: 4
                    height: 4
                    radius: 2
                    color: Theme.menuBarTextColor
                    visible: NotificationService.notificationCount > 0
                }
            }

            MenuBarButton {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                fontFamily: Typography.menuBarFontFamily
                fontSize: 12
                selected: root.notificationsOpen
                onClicked: {
                    VolumeService.hide();
                    LauncherState.visible = false;
                    ControlCenterState.visible = false;
                    root.notificationsOpen = !root.notificationsOpen;
                }
            }
        }
    }

    LauncherWindow { targetScreen: root.screen }

    PanelWindow {
        id: volumeWindow
        property real reveal: root.volumeOpen ? 1 : 0

        screen: root.screen
        visible: root.volumeOpen || reveal > 0
        color: "transparent"
        implicitWidth: volumePanel.implicitWidth
        implicitHeight: volumePanel.implicitHeight
        exclusionMode: ExclusionMode.Ignore
        anchors { bottom: true }
        // Keep the HUD center at three quarters of the output height.
        margins.bottom: Math.max(0, Math.round(root.screen.height * 0.25 - implicitHeight / 2))
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-volume"
        WlrLayershell.keyboardFocus: root.volumeOpen && !VolumeService.autoHide
            ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        BackgroundEffect.blurRegion: Region { item: volumePanel; radius: volumePanel.radius }
        mask: Region { item: root.volumeOpen ? volumePanel : null; radius: volumePanel.radius }

        Behavior on reveal {
            NumberAnimation { duration: root.volumeOpen ? 100 : 180 }
        }

        VolumePanel {
            id: volumePanel
            anchors.fill: parent
            opacity: volumeWindow.reveal
            enabled: root.volumeOpen
            focus: root.volumeOpen
            Keys.onEscapePressed: VolumeService.hide()
        }
    }

    ControlCenterWindow { targetScreen: root.screen; barHeight: root.implicitHeight }

    PanelWindow {
        screen: root.screen
        visible: root.notificationsOpen
        color: "transparent"
        implicitWidth: Math.min(380, root.screen.width)
        implicitHeight: Math.max(1, Math.min(600, root.screen.height - 64))
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: root.implicitHeight + 8; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-notification-history"
        BackgroundEffect.blurRegion: Region { item: historyBackground; radius: historyBackground.radius }
        WlrLayershell.keyboardFocus: root.notificationsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        Rectangle {
            id: historyBackground
            anchors.fill: parent
            color: Theme.shellBackgroundColor
            radius: 20
            border.color: Theme.surfaceBorderColor
            NotificationPanel {
                anchors.fill: parent
                anchors.margins: 16
                focus: root.notificationsOpen
                Keys.onEscapePressed: root.notificationsOpen = false
            }
        }
    }

    PanelWindow {
        screen: root.screen
        visible: NotificationService.popupNotificationCount > 0 && !root.notificationsOpen && !root.controlCenterOpen
        color: "transparent"
        implicitWidth: Math.min(380, root.screen.width)
        implicitHeight: stack.desiredHeight
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: root.implicitHeight + 8; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-notification-popups"
        BackgroundEffect.blurRegion: stack.blurRegion

        NotificationStack {
            id: stack
            anchors.fill: parent
            maximumHeight: Math.max(1, root.screen.height - 64)
        }
    }
}
