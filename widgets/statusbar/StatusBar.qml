import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/theme"
import "../../services"
import "../notifications"
import "../launcher"
import "../brightness"
import "../../components/state"

PanelWindow {
    id: root

    required property var modelData

    property bool notificationsOpen: false
    property bool brightnessOpen: false

    Binding {
        target: BrightnessService
        property: "active"
        value: true
        when: root.brightnessOpen
        restoreMode: Binding.RestoreBindingOrValue
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
                    root.brightnessOpen = false;
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
                text: Icons.brightness
                selected: root.brightnessOpen
                onClicked: {
                    LauncherState.visible = false;
                    root.notificationsOpen = false;
                    root.brightnessOpen = !root.brightnessOpen;
                }
            }

            MenuBarButton {
                text: Icons.notifications
                selected: root.notificationsOpen
                onClicked: {
                    LauncherState.visible = false;
                    root.brightnessOpen = false;
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
                text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
                fontFamily: Typography.menuBarFontFamily
                fontSize: 12
                selected: root.notificationsOpen
                onClicked: {
                    LauncherState.visible = false;
                    root.brightnessOpen = false;
                    root.notificationsOpen = !root.notificationsOpen;
                }
            }
        }
    }

    LauncherWindow { targetScreen: root.screen }

    PanelWindow {
        screen: root.screen
        visible: root.brightnessOpen
        color: "transparent"
        implicitWidth: Math.min(360, root.screen.width)
        implicitHeight: Math.min(brightnessPanel.implicitHeight + 32, root.screen.height - 64)
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: root.implicitHeight + 8; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-brightness"
        BackgroundEffect.blurRegion: Region { item: brightnessBackground; radius: brightnessBackground.radius }
        WlrLayershell.keyboardFocus: root.brightnessOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        Rectangle {
            id: brightnessBackground
            anchors.fill: parent
            color: Theme.shellBackgroundColor
            radius: 20
            border.color: Theme.surfaceBorderColor
            BrightnessPanel {
                id: brightnessPanel
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                focus: root.brightnessOpen
                Keys.onEscapePressed: root.brightnessOpen = false
            }
        }
    }

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
        visible: NotificationService.popupNotificationCount > 0 && !root.notificationsOpen
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
