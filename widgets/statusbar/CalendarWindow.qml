import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var targetScreen
    required property date today
    property int barHeight: 30
    property bool opened: false
    signal dismissed()

    screen: targetScreen
    visible: opened
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-calendar"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: panel; radius: panel.radius }

    onOpenedChanged: if (opened) panel.resetMonth()
    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(() => panel.forceActiveFocus())

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
        onWheel: wheel => { wheel.accepted = true; }
    }

    CalendarPanel {
        id: panel
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: root.barHeight + 8 }
        width: Math.min(implicitWidth, root.width - 16)
        today: root.today
        focus: root.opened
        Keys.onEscapePressed: root.dismissed()
    }
}
