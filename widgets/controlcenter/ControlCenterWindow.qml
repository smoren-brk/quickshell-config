import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../components/theme"
import "../../components/state"

PanelWindow {
    id: root

    required property var targetScreen
    property int barHeight: 30
    readonly property bool opened: ControlCenterState.visible
        && ControlCenterState.outputName === targetScreen.name
    property real reveal: opened ? 1 : 0

    screen: targetScreen
    visible: opened || reveal > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-control-center"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: panel; radius: panel.radius }
    mask: Region { item: root.opened ? backdrop : null }

    onOpenedChanged: if (opened) Qt.callLater(() => panel.forceActiveFocus())
    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(() => panel.forceActiveFocus())

    Behavior on reveal {
        NumberAnimation { duration: root.opened ? 120 : 100 }
    }

    MouseArea {
        id: backdrop
        anchors.fill: parent
        onClicked: ControlCenterState.visible = false
        onWheel: wheel => { wheel.accepted = true; }
    }

    Rectangle {
        id: panel
        anchors { top: parent.top; right: parent.right; topMargin: root.barHeight + 8; rightMargin: 8 }
        width: Math.min(360, root.width - 16)
        height: Math.min(content.implicitHeight + 24, root.height - y - 8)
        radius: 20
        color: Theme.shellBackgroundColor
        border.color: Theme.menuBarBorderColor
        opacity: root.reveal
        enabled: root.opened
        focus: root.opened
        Keys.onEscapePressed: ControlCenterState.visible = false

        // Keep clicks inside the card from reaching the dismissal backdrop.
        MouseArea { anchors.fill: parent }

        ScrollView {
            anchors.fill: parent
            anchors.margins: 12
            contentWidth: availableWidth
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ControlCenterPanel {
                id: content
                width: parent.width
            }
        }
    }
}
