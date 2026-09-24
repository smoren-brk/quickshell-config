import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    required property var record
    property int groupCount: 1
    property bool groupExpanded: false
    readonly property var actions: record ? record.actions.filter(action => action.identifier !== "default") : []
    readonly property bool hasDefaultAction: record ? record.actions.some(action => action.identifier === "default") : false

    signal expansionRequested()

    implicitHeight: content.implicitHeight + 24
    radius: 14
    color: Theme.notificationCardColor
    border.color: Theme.notificationBorderColor

    SystemClock { id: clock; precision: SystemClock.Minutes }

    function timeLabel(): string {
        if (!record)
            return "";
        const received = new Date(record.receivedAt);
        const now = clock.date;
        if (now.getTime() - received.getTime() < 60000)
            return "now";
        if (now.toDateString() === received.toDateString())
            return Qt.formatTime(received, "HH:mm");
        const yesterday = new Date(now);
        yesterday.setDate(yesterday.getDate() - 1);
        return (yesterday.toDateString() === received.toDateString() ? "Yesterday" : Qt.formatDate(received, "MMM d"))
            + ", " + Qt.formatTime(received, "HH:mm");
    }

    // Keep the body target separate from action and group buttons.
    MouseArea {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: content.y + message.y + message.height
        enabled: root.groupCount > 1 && !root.groupExpanded || root.hasDefaultAction
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.groupCount > 1 && !root.groupExpanded)
                root.expansionRequested();
            else
                NotificationService.invokeAction(root.record.notificationId, "default");
        }
    }

    Column {
        id: content
        x: 14
        y: 12
        width: Math.max(0, root.width - 28)
        spacing: 8

        RowLayout {
            width: parent.width
            height: 20
            spacing: 7

            Rectangle {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                radius: 4
                color: Theme.notificationIconColor

                IconImage {
                    id: appIcon
                    anchors.fill: parent
                    source: root.record ? root.record.icon : ""
                    visible: root.record !== null && root.record.icon !== "" && status !== Image.Error
                }

                Text {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    text: Icons.notifications
                    color: Theme.notificationLabelColor
                    font.family: Typography.nerdIconFontFamily
                    font.pixelSize: 13
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.record ? root.record.appName.toUpperCase() : ""
                textFormat: Text.PlainText
                color: Theme.notificationLabelColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                font.letterSpacing: 0.3
                elide: Text.ElideRight
            }

            Text {
                text: root.timeLabel()
                color: Theme.notificationLabelColor
                opacity: 0.8
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 10
            }

            NotificationButton {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                text: "×"
                font.pixelSize: 16
                padding: 0
                leftPadding: 0
                rightPadding: 0
                Accessible.name: "Dismiss notification"
                background: Rectangle {
                    radius: 10
                    color: parent.hovered || parent.visualFocus ? Theme.menuBarSelectedColor : "transparent"
                }
                onClicked: NotificationService.dismissById(root.record.notificationId)
            }
        }

        Column {
            id: message
            width: parent.width
            spacing: 2

            Text {
                width: parent.width
                text: root.record ? root.record.summary : ""
                textFormat: Text.PlainText
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: root.record ? root.record.body : ""
                textFormat: Text.PlainText
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 13
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
        }

        GridLayout {
            width: parent.width
            visible: root.actions.length > 0
            columns: 2
            rowSpacing: 6
            columnSpacing: 8

            Repeater {
                model: root.actions
                NotificationButton {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.columnSpan: root.actions.length % 2 === 1 && index === root.actions.length - 1 ? 2 : 1
                    text: modelData.text
                    onClicked: NotificationService.invokeAction(root.record.notificationId, modelData.identifier)
                }
            }
        }

        NotificationButton {
            width: parent.width
            visible: root.groupCount > 1
            text: root.groupExpanded ? "Show less" : (root.groupCount - 1) + " more notification" + (root.groupCount === 2 ? "" : "s")
            onClicked: root.expansionRequested()
        }
    }
}
