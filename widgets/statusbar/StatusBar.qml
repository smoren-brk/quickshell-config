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
    implicitHeight: 40
    exclusiveZone: 40

    anchors {
        top: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qqq-bar"

    Rectangle {
        anchors.fill: parent
        color: Theme.shellBackgroundColor

        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15

            MouseArea {
                anchors.centerIn: parent
                width: parent.width + 24
                height: 40
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.notificationsOpen = false;
                    root.brightnessOpen = false;
                    LauncherState.toggleForOutput(root.screen.name);
                }
            }
        }

        Rectangle {
            id: brightnessButton
            anchors.right: notificationButton.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: 14
            color: root.brightnessOpen ? Theme.surfaceBorderColor : Theme.panelSurfaceColor
            Text {
                anchors.centerIn: parent
                text: Icons.brightness
                color: Theme.accentHoverColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 18
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    LauncherState.visible = false;
                    root.notificationsOpen = false;
                    root.brightnessOpen = !root.brightnessOpen;
                }
            }
        }

        SystemTraySection {
            id: tray
            barWindow: root
            anchors.right: brightnessButton.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: notificationButton
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: bellRow.width + 20
            height: 28
            radius: 14
            color: root.notificationsOpen ? Theme.surfaceBorderColor : Theme.panelSurfaceColor

            Row {
                id: bellRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: Icons.notifications
                    color: NotificationService.notificationCount > 0
                        ? Theme.accentHoverColor : Theme.primaryTextColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 16
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    LauncherState.visible = false;
                    root.brightnessOpen = false;
                    root.notificationsOpen = !root.notificationsOpen;
                }
            }
        }

        StatusBarWorkspaceSection {
            outputName: root.screen.name
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
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
        margins { top: 48; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-brightness"
        WlrLayershell.keyboardFocus: root.brightnessOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        Rectangle {
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
        margins { top: 48; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-notification-history"
        WlrLayershell.keyboardFocus: root.notificationsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        Rectangle {
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
        margins { top: 48; right: 8 }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qqq-notification-popups"

        NotificationStack {
            id: stack
            anchors.fill: parent
            maximumHeight: Math.max(1, root.screen.height - 64)
        }
    }
}
