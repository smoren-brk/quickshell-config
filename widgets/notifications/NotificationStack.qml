import QtQuick
import Quickshell
import "../../services"

Item {
    id: root

    property real maximumHeight: 600
    property string hoverKey: "popups"
    readonly property real desiredHeight: NotificationService.popupNotificationCount > 0
        ? Math.min(maximumHeight, list.desiredHeight + 32) : 1
    readonly property Region blurRegion: list.blurRegion

    onVisibleChanged: if (!visible) {
        NotificationService.holdPopups(hoverKey, false);
        list.reset();
    }
    Component.onDestruction: NotificationService.holdPopups(hoverKey, false)

    NotificationList {
        id: list
        anchors.fill: parent
        anchors.margins: 16
        maximumHeight: Math.max(0, root.maximumHeight - 32)
        groups: NotificationService.popupGroups
        popup: true
    }

    HoverHandler {
        onHoveredChanged: NotificationService.holdPopups(root.hoverKey, hovered && root.visible)
    }
}
