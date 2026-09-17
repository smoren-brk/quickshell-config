import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/theme"
import "../../components/state"

PanelWindow {
    id: root
    required property var targetScreen
    readonly property bool opened: LauncherState.visible && LauncherState.outputName === targetScreen.name
    property real reveal: opened ? 1 : 0

    screen: targetScreen
    visible: opened || reveal > 0
    color: "transparent"
    implicitWidth: Math.max(1, Math.min(620, targetScreen.width - 32))
    implicitHeight: launcher.desiredHeight
    exclusionMode: ExclusionMode.Ignore
    anchors.top: true
    margins.top: 40
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-launcher"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    mask: Region { item: panel }

    function focusSearch(): void {
        if (opened)
            launcher.focusTarget.forceActiveFocus();
    }
    onOpenedChanged: if (opened) Qt.callLater(focusSearch)
    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(focusSearch)

    Behavior on reveal {
        NumberAnimation { duration: 360; easing.type: Easing.OutCubic }
    }
    Behavior on implicitHeight {
        enabled: root.visible
        NumberAnimation { duration: launcher.resizeDurationMs; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: panel
        width: root.width
        height: root.height
        y: (root.reveal - 1) * height
        color: Theme.shellBackgroundColor
        bottomLeftRadius: 20
        bottomRightRadius: 20
        clip: true

        ApplicationLauncher {
            id: launcher
            anchors.fill: parent
            maximumHeight: Math.max(1, Math.min(620, root.targetScreen.height - 56))
            shown: root.opened
            enabled: root.opened
            onCloseRequested: LauncherState.visible = false
        }
    }
}
