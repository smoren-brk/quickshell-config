import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../components/theme"

PanelWindow {
    id: root

    required property var targetScreen
    property int barHeight: 30
    property bool opened: false
    signal dismissed()

    screen: targetScreen
    visible: opened
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-system-menu"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: panel; radius: panel.radius }

    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(() => panel.forceActiveFocus())

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
        onWheel: wheel => { wheel.accepted = true; }
    }

    Rectangle {
        id: panel
        anchors { top: parent.top; left: parent.left; topMargin: root.barHeight + 2; leftMargin: 10 }
        width: 250
        height: entries.implicitHeight + 12
        radius: 9
        color: Theme.menuBarBackgroundColor
        border.color: Theme.spotlightBorderColor
        focus: root.opened
        Keys.onEscapePressed: root.dismissed()

        MouseArea { anchors.fill: parent }

        Column {
            id: entries
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }

            MenuEntry { text: "About this NixOS" }
            MenuSeparator {}
            MenuEntry {
                text: "Restart…"
                command: ["systemctl", "reboot"]
            }
            MenuEntry {
                text: "Shut Down…"
                command: ["systemctl", "poweroff"]
            }
            MenuSeparator {}
            MenuEntry { text: "Lock Screen" }
            MenuEntry {
                text: "Log Out…"
                command: ["niri", "msg", "action", "quit", "--skip-confirmation"]
            }
        }
    }

    component MenuEntry: ItemDelegate {
        id: entry
        property var command: []
        width: entries.width
        height: 30
        hoverEnabled: true
        onClicked: {
            root.dismissed();
            if (command.length > 0)
                Quickshell.execDetached(command);
        }
        contentItem: Text {
            text: entry.text
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 13
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
        }
        background: Rectangle {
            radius: 4
            color: entry.hovered || entry.activeFocus ? Theme.spotlightSelectionColor : "transparent"
        }
    }

    component MenuSeparator: Item {
        width: entries.width
        height: 9
        Rectangle {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
            height: 1
            color: Theme.menuBarBorderColor
        }
    }
}
