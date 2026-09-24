import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components/theme"
import "../../services"

Item {
    id: root

    property real maximumHeight: 600
    readonly property real desiredHeight: Math.min(maximumHeight, 54 + (NotificationService.notificationCount > 0 ? list.desiredHeight : 90))
    readonly property Region blurRegion: Region {
        Region { item: header; radius: header.radius }
        Region { regions: [list.blurRegion] }
        Region { item: emptyState.visible ? emptyState : null; radius: emptyState.radius }
    }

    onVisibleChanged: if (!visible) list.reset()

    Rectangle {
        id: header
        width: parent.width
        height: 40
        radius: 14
        color: Theme.notificationCardColor
        border.color: Theme.notificationBorderColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 8

            Text {
                Layout.fillWidth: true
                text: "Notifications"
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            NotificationButton {
                visible: NotificationService.notificationCount > 0
                text: "Clear all"
                onClicked: NotificationService.clear()
            }
        }
    }

    NotificationList {
        id: list
        y: 54
        width: parent.width
        height: Math.max(0, parent.height - y)
        maximumHeight: Math.max(0, root.maximumHeight - y)
        groups: NotificationService.notificationGroups
    }

    Rectangle {
        id: emptyState
        y: 54
        width: parent.width
        height: 90
        visible: NotificationService.notificationCount === 0
        radius: 14
        color: Theme.notificationCardColor
        border.color: Theme.notificationBorderColor

        Text {
            anchors.centerIn: parent
            text: "No notifications"
            color: Theme.notificationLabelColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 13
        }
    }
}
