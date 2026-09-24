import QtQuick
import QtQuick.Controls
import Quickshell
import "../../components/theme"
import "../../services/NotificationData.js" as NotificationData

Item {
    id: root
    objectName: "notificationList"

    property var groups: []
    property real maximumHeight: 600
    property bool popup: false
    property bool showAll: false
    property var expandedSources: ({})
    readonly property var fit: {
        const heights = [];
        const counts = [];
        for (let index = 0; index < groupRepeater.count; index++) {
            const item = groupRepeater.itemAt(index);
            if (!item)
                continue;
            heights.push(item.implicitHeight);
            counts.push(item.count);
        }
        return NotificationData.fitGroups(heights, counts, maximumHeight, 14, 40);
    }
    readonly property int hiddenCount: fit.hiddenCount
    readonly property real footerHeight: hiddenCount > 0 || showAll ? 40 : 0
    readonly property real desiredHeight: Math.min(maximumHeight, groupColumn.implicitHeight + footerHeight)
    readonly property Region blurRegion: Region {
        Region {
            Region {
                regions: Array.from(groupColumn.children).filter(child => child.visible && child.blurRegion)
                    .map(child => child.blurRegion)
            }
            Region { item: viewport; intersection: Intersection.Intersect }
        }
        Region { item: footer.visible ? footer : null; radius: 14 }
    }

    function reset(): void {
        showAll = false;
        expandedSources = ({});
        viewport.contentY = 0;
    }

    function toggleGroup(sourceKey: string): void {
        const expanded = Object.assign({}, expandedSources);
        expanded[sourceKey] = !expanded[sourceKey];
        expandedSources = expanded;
    }

    onGroupsChanged: if (groups.length === 0) reset()

    Flickable {
        id: viewport
        width: parent.width
        height: Math.max(0, parent.height - root.footerHeight)
        contentWidth: width
        contentHeight: groupColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        onContentHeightChanged: returnToBounds()

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
            contentItem: Rectangle {
                implicitWidth: 3
                radius: 2
                color: Theme.notificationLabelColor
                opacity: parent.active ? 0.7 : 0.3
            }
        }

        Column {
            id: groupColumn
            width: parent.width
            spacing: 14

            Repeater {
                id: groupRepeater
                model: root.groups.length

                NotificationGroup {
                    required property int index
                    width: groupColumn.width
                    group: root.groups[index] || null
                    visible: root.showAll || index < root.fit.visibleCount
                    expanded: group ? !!root.expandedSources[group.sourceKey] : false
                    popup: root.popup
                    onExpansionRequested: root.toggleGroup(group.sourceKey)
                }
            }
        }
    }

    NotificationButton {
        id: footer
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
        visible: root.footerHeight > 0
        text: root.showAll ? "Show less" : root.hiddenCount + " more notification" + (root.hiddenCount === 1 ? "" : "s")
        background: Rectangle {
            radius: 14
            color: Theme.notificationCardColor
            border.color: footer.hovered || footer.visualFocus ? Theme.notificationLabelColor : Theme.notificationBorderColor
        }
        onClicked: {
            root.showAll = !root.showAll;
            viewport.contentY = 0;
        }
    }
}
