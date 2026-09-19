import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Item {
    id: root

    required property var result
    required property bool selected

    signal hoverRequested
    signal launchRequested

    Accessible.role: Accessible.Button
    Accessible.name: result.name
    Accessible.description: result.description
    Accessible.onPressAction: launchRequested()

    Item {
        id: applicationIcon
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32

        Rectangle {
            anchors.fill: parent
            radius: 7
            color: Theme.menuBarHoverColor
            visible: !artwork.visible

            Text {
                anchors.centerIn: parent
                text: root.result.kind === "executable" ? "" : ""
                color: Theme.menuBarTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 19
            }
        }

        IconImage {
            id: artwork
            anchors.fill: parent
            source: root.result.kind === "app" && root.result.icon && (root.result.icon.startsWith("/") || Quickshell.hasThemeIcon(root.result.icon)) ? Quickshell.iconPath(root.result.icon) : ""
            asynchronous: true
            visible: status === Image.Ready
        }
    }

    Column {
        anchors.left: applicationIcon.right
        anchors.right: openIndicator.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 2

        Text {
            width: parent.width
            text: root.result.name
            textFormat: Text.PlainText
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.result.description
            textFormat: Text.PlainText
            color: root.selected ? "#e5edff" : Theme.spotlightSecondaryTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
            visible: text.length > 0
        }
    }

    Text {
        id: openIndicator
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        text: "↵"
        opacity: root.selected ? 1 : 0
        color: Theme.menuBarTextColor
        font.family: Typography.menuBarFontFamily
        font.pixelSize: 16
    }

    MouseArea {
        id: pointer
        property point lastPosition
        property bool tracking: false
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Layout and scrolling also generate position events. Compare global
        // coordinates so only actual pointer movement changes the selection.
        onEntered: {
            lastPosition = mapToGlobal(mouseX, mouseY);
            tracking = true;
        }
        onExited: tracking = false
        onPositionChanged: mouse => {
            const position = mapToGlobal(mouse.x, mouse.y);
            if (containsMouse && tracking && (position.x !== lastPosition.x || position.y !== lastPosition.y))
                root.hoverRequested();
            lastPosition = position;
        }
        onClicked: root.launchRequested()
    }
}
