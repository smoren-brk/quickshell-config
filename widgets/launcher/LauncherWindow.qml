import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../components/state"

PanelWindow {
    id: root

    required property var targetScreen
    readonly property bool opened: LauncherState.visible && LauncherState.outputName === targetScreen.name
    property real reveal: opened ? 1 : 0

    screen: targetScreen
    visible: opened || reveal > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-launcher"
    BackgroundEffect.blurRegion: launcher.blurRegion
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // Release pointer input immediately while the closing animation finishes.
    mask: Region {
        item: root.opened ? backdrop : null
    }

    function focusSearch(): void {
        if (opened)
            launcher.focusTarget.forceActiveFocus();
    }

    // Region watches the panel rectangles, but not their ancestors' transforms.
    // Republish after the launcher moves or scales so the compositor stays aligned.
    TransformWatcher {
        a: root.contentItem
        b: launcher
        onTransformChanged: launcher.blurRegion.changed()
    }

    onOpenedChanged: if (opened)
        Qt.callLater(focusSearch)
    onBackingWindowVisibleChanged: if (backingWindowVisible)
        Qt.callLater(focusSearch)

    Behavior on reveal {
        NumberAnimation {
            duration: root.opened ? 200 : 140
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        id: backdrop
        anchors.fill: parent
        enabled: root.opened
        acceptedButtons: Qt.AllButtons
        onClicked: LauncherState.visible = false
        onWheel: event => {
            event.accepted = true;
        }
    }

    Item {
        id: panel
        readonly property real topOffset: Math.max(16, Math.min(root.height * 0.2, root.height - 220))
        anchors.horizontalCenter: parent.horizontalCenter
        y: topOffset - 8 * (1 - root.reveal)
        width: Math.max(1, Math.min(720, root.width - 32))
        height: launcher.desiredHeight
        opacity: root.reveal
        scale: 0.98 + 0.02 * root.reveal
        transformOrigin: Item.Top
        enabled: root.opened

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: launcher.focusTarget.forceActiveFocus()
            onWheel: event => {
                event.accepted = true;
            }
        }

        ApplicationLauncher {
            id: launcher
            anchors.fill: parent
            maximumHeight: Math.max(0, root.height - panel.topOffset - 24)
            blurScale: panel.scale
            shown: root.opened
            onCloseRequested: LauncherState.visible = false
        }
    }
}
