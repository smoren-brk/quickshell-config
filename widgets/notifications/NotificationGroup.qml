import QtQuick
import Quickshell
import "../../components/theme"

Item {
    id: root

    required property var group
    property bool expanded: false
    property bool popup: false
    readonly property int count: group ? group.records.length : 0
    readonly property int latestId: count > 0 ? group.records[0].notificationId : -1
    readonly property real stackDepth: expanded ? 0 : Math.min(2, Math.max(0, count - 1)) * 7
    readonly property Region blurRegion: Region {
        Region { item: backSheet.visible ? backSheet : null; radius: 8 }
        Region { item: middleSheet.visible ? middleSheet : null; radius: 8 }
        Region {
            regions: Array.from(cards.children).filter(child => child instanceof NotificationCard)
                .map(child => child.cardRegion)
        }
    }

    signal expansionRequested()

    implicitHeight: cards.implicitHeight + stackDepth
    height: implicitHeight

    // Only paint the exposed edges, preserving the front card's 70% opacity.
    Item {
        id: backSheet
        x: 20
        y: cards.height - 1 + 7
        width: Math.max(0, root.width - 40)
        height: 8
        clip: true
        visible: !root.expanded && root.count > 2
        Rectangle {
            width: parent.width
            height: 28
            y: parent.height - height
            radius: 14
            color: Theme.notificationCardColor
            border.color: Theme.notificationBorderColor
        }
    }

    Item {
        id: middleSheet
        x: 10
        y: cards.height - 1
        width: Math.max(0, root.width - 20)
        height: 8
        clip: true
        visible: !root.expanded && root.count > 1
        Rectangle {
            width: parent.width
            height: 28
            y: parent.height - height
            radius: 14
            color: Theme.notificationCardColor
            border.color: Theme.notificationBorderColor
        }
    }

    Column {
        id: cards
        width: parent.width
        spacing: 8

        Repeater {
            model: root.expanded ? root.count : Math.min(1, root.count)

            NotificationCard {
                id: card
                required property int index
                readonly property Region cardRegion: Region { item: card; radius: card.radius }
                width: cards.width
                record: root.group ? root.group.records[index] : null
                groupCount: index === 0 ? root.count : 1
                groupExpanded: root.expanded
                onExpansionRequested: root.expansionRequested()
            }
        }
    }

    property real slideOffset: 0
    transform: Translate { x: root.slideOffset }
    onSlideOffsetChanged: blurRegion.changed()
    onLatestIdChanged: if (popup && latestId >= 0) arrival.restart()

    NumberAnimation {
        id: arrival
        target: root
        property: "slideOffset"
        from: 28
        to: 0
        duration: 220
        easing.type: Easing.OutCubic
    }
}
