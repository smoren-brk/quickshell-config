import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import "../../components/theme"
import "../../services"

Flickable {
    id: root
    required property string outputName
    property real maximumWidth: 360
    readonly property var groups: {
        const workspaceIds = NiriService.workspacesForOutput(outputName).map(ws => ws.id);
        const result = [];
        for (const window of NiriService.windows) {
            if (!workspaceIds.includes(window.workspaceId)) continue;
            const key = window.appId || String(window.id);
            let group = result.find(app => app.key === key);
            if (!group) {
                const entry = DesktopEntries.heuristicLookup(window.appId);
                group = { key, name: entry?.name || window.appId || window.title,
                    icon: entry?.icon || window.appId, windows: [], focused: false, urgent: false };
                result.push(group);
            }
            group.windows.push(window);
            group.focused = group.focused || window.isFocused;
            group.urgent = group.urgent || window.isUrgent;
        }
        return result;
    }
    implicitWidth: Math.min(appRow.width, maximumWidth)
    implicitHeight: 42
    contentWidth: appRow.width
    contentHeight: height
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalFlick

    Row {
        id: appRow
        spacing: 4
        Repeater {
            model: root.groups
            Rectangle {
                id: app
                required property var modelData
                width: 42
                height: 42
                radius: 6
                color: mouse.containsMouse || modelData.focused ? Theme.selectedSurfaceColor : "transparent"
                Behavior on color { ColorAnimation { duration: 110 } }

                IconImage {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 5
                    implicitSize: 28
                    source: Quickshell.iconPath(app.modelData.icon, true) || Qt.resolvedUrl("../../components/theme/application.svg")
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 38
                    width: app.modelData.focused ? 16 : app.modelData.windows.length > 1 ? 9 : 4
                    height: 2
                    radius: 1
                    color: app.modelData.urgent ? Theme.dangerColor : app.modelData.focused ? Theme.accentColor : Theme.mutedTextColor
                    Behavior on width { NumberAnimation { duration: 110 } }
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const windows = app.modelData.windows;
                        const current = windows.findIndex(window => window.isFocused);
                        NiriService.activateWindow(windows[(current + 1) % windows.length].id);
                    }
                    onWheel: event => {
                        root.contentX = Math.max(0, Math.min(root.contentWidth - root.width,
                            root.contentX - (event.angleDelta.y || event.angleDelta.x)));
                        event.accepted = true;
                    }
                }
                ToolTip.visible: mouse.containsMouse
                ToolTip.delay: 600
                ToolTip.text: modelData.name + (modelData.windows.length > 1 ? " · " + modelData.windows.length + " windows" : "")
            }
        }
    }
}
