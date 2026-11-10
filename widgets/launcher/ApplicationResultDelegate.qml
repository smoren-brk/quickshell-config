import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Rectangle {
    id: root
    required property var entry
    required property bool selected
    property string actionLabel: "Open ↵"
    signal hoverRequested()
    signal launchRequested()
    radius: 6
    color: selected ? Theme.selectedSurfaceColor : "transparent"

    Rectangle {
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 18
        radius: 1.5
        visible: root.selected
        color: Theme.accentColor
    }
    IconImage {
        x: 14
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 30
        visible: !root.entry.glyph
        source: visible ? Quickshell.iconPath(root.entry.icon || "", true) || Qt.resolvedUrl("../../components/theme/application.svg") : ""
    }
    Text {
        x: 14
        width: 30
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        visible: !!root.entry.glyph
        text: root.entry.glyph || ""
        color: Theme.secondaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 25
    }
    Column {
        x: 58
        width: Math.max(0, parent.width - x - action.width - 32)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Text {
            width: parent.width
            text: root.entry.name
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
        }
        Text {
            width: parent.width
            text: root.entry.subtitle || "Application"
            color: Theme.secondaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }
    Text {
        id: action
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        visible: root.selected
        text: root.actionLabel
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 11
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Movement, rather than entry during a resize, changes the selection.
        onPositionChanged: root.hoverRequested()
        onClicked: root.launchRequested()
    }
}
