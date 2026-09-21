import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import "../../components/theme"

Rectangle {
    id: root
    required property var barWindow
    property bool expanded: false
    width: visible ? 26 + reveal.width : 0
    visible: SystemTray.items.values.length > 0
    height: 26
    radius: 5
    color: "transparent"

    Item {
        id: reveal
        anchors.left: parent.left
        height: parent.height
        width: root.expanded && icons.width > 0 ? icons.width + 4 : 0
        clip: true
        enabled: root.expanded

        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Row {
            id: icons
            height: parent.height
            spacing: 4
            Repeater {
                model: SystemTray.items
        
                Rectangle {
                    id: trayItem
                    required property var modelData
                    width: 26
                    height: 26
                    radius: 5
                    color: mouse.containsMouse ? Theme.menuBarHoverColor : "transparent"
        
                    function showMenu(): void {
                        if (modelData.hasMenu) {
                            const point = mapToItem(null, 0, height);
                            modelData.display(root.barWindow, Math.round(point.x), Math.round(point.y));
                        }
                    }
        
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 16
                        source: trayItem.modelData.icon
                    }
        
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: event => {
                            if (event.button === Qt.RightButton)
                                trayItem.showMenu();
                            else if (event.button === Qt.MiddleButton)
                                trayItem.modelData.secondaryActivate();
                            else if (trayItem.modelData.onlyMenu)
                                trayItem.showMenu();
                            else
                                trayItem.modelData.activate();
                        }
                        onWheel: event => {
                            if (event.angleDelta.y !== 0)
                                trayItem.modelData.scroll(event.angleDelta.y, false);
                            else if (event.angleDelta.x !== 0)
                                trayItem.modelData.scroll(event.angleDelta.x, true);
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        width: 26
        height: 26
        radius: 5
        color: toggleMouse.containsMouse ? Theme.menuBarHoverColor : "transparent"

        Text {
            anchors.centerIn: parent
            text: root.expanded ? "›" : "‹"
            color: Theme.menuBarTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 18
        }

        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }
}
