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
    property var pendingAction: null
    readonly property bool confirmingAction: pendingAction !== null
    signal dismissed()
    signal aboutRequested()

    onOpenedChanged: if (!opened) pendingAction = null
    onConfirmingActionChanged: if (confirmingAction) Qt.callLater(() => cancelButton.forceActiveFocus())

    screen: targetScreen
    visible: opened
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-system-menu"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region {
        item: root.confirmingAction ? confirmationDialog : panel
        radius: root.confirmingAction ? confirmationDialog.radius : panel.radius
    }

    onBackingWindowVisibleChanged: if (backingWindowVisible) Qt.callLater(() => panel.forceActiveFocus())

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
        onWheel: wheel => { wheel.accepted = true; }
    }

    Rectangle {
        id: panel
        visible: !root.confirmingAction
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

            MenuEntry { text: "About this NixOS"; opensAbout: true }
            MenuSeparator {}
            MenuEntry {
                text: "Restart…"
                command: ["systemctl", "reboot"]
                confirmationLabel: "Restart"
                confirmationQuestion: "Are you sure you want to restart your computer?"
                confirmationDetail: "Save your work before restarting."
            }
            MenuEntry {
                text: "Shut Down…"
                command: ["systemctl", "poweroff"]
                confirmationLabel: "Shut Down"
                confirmationQuestion: "Are you sure you want to shut down your computer?"
                confirmationDetail: "Save your work before shutting down."
            }
            MenuSeparator {}
            MenuEntry { text: "Lock Screen" }
            MenuEntry {
                text: "Log Out…"
                command: ["niri", "msg", "action", "quit", "--skip-confirmation"]
                confirmationLabel: "Log Out"
                confirmationQuestion: "Are you sure you want to log out of your session?"
                confirmationDetail: "Save your work before exiting niri."
            }
        }
    }

    Rectangle {
        id: confirmationDialog
        visible: root.confirmingAction
        anchors.centerIn: parent
        width: Math.min(320, root.width - 32)
        height: dialogContent.implicitHeight + 56
        radius: 16
        color: Theme.menuBarBackgroundColor
        border.color: Theme.spotlightBorderColor
        Keys.onEscapePressed: root.dismissed()

        MouseArea { anchors.fill: parent }

        Column {
            id: dialogContent
            anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 24; rightMargin: 24; topMargin: 28 }
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u23fb"
                color: Theme.menuBarTextColor
                font.family: Typography.symbolIconFontFamily
                font.pixelSize: 40
            }

            Text {
                width: parent.width
                text: root.pendingAction ? root.pendingAction.question : ""
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: root.pendingAction ? root.pendingAction.detail : ""
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 12
            }

            Column {
                width: parent.width
                spacing: 8

                DialogButton {
                    id: cancelButton
                    text: "Cancel"
                    width: parent.width
                    onClicked: root.dismissed()
                }

                DialogButton {
                    text: root.pendingAction ? root.pendingAction.label : ""
                    primary: true
                    width: parent.width
                    onClicked: {
                        if (!root.pendingAction)
                            return;
                        const command = root.pendingAction.command;
                        root.dismissed();
                        Quickshell.execDetached(command);
                    }
                }
            }
        }
    }

    component DialogButton: Button {
        id: button
        property bool primary: false
        height: 36
        hoverEnabled: true
        contentItem: Text {
            text: button.text
            color: button.primary ? Theme.neutralSelectionTextColor : Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 7
            color: button.primary ? Theme.neutralSelectionColor
                : button.hovered || button.down ? Theme.menuBarSelectedColor : Theme.menuBarHoverColor
            border.width: button.activeFocus ? 2 : 1
            border.color: button.activeFocus ? Theme.neutralSelectionColor : Theme.menuBarBorderColor
        }
    }

    component MenuEntry: ItemDelegate {
        id: entry
        property var command: []
        property bool opensAbout: false
        property string confirmationLabel: ""
        property string confirmationQuestion: ""
        property string confirmationDetail: ""
        width: entries.width
        height: 30
        hoverEnabled: true
        onClicked: {
            if (opensAbout) {
                root.dismissed();
                root.aboutRequested();
                return;
            }
            if (confirmationLabel.length > 0) {
                root.pendingAction = {
                    label: confirmationLabel,
                    question: confirmationQuestion,
                    detail: confirmationDetail,
                    command: command.slice()
                };
                return;
            }
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
