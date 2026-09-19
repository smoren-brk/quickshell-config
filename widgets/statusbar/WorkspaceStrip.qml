import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName
    readonly property var workspaces: NiriService.workspacesForOutput(outputName)

    implicitWidth: workspaceRow.width
    implicitHeight: 26

    Row {
        id: workspaceRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Repeater {
            model: root.workspaces

            Rectangle {
                id: workspace
                required property var modelData

                width: 22
                height: 26
                radius: 5
                color: mouse.containsMouse ? Theme.menuBarHoverColor : "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: workspace.modelData.isActive ? 16 : 5
                    height: 5
                    radius: height / 2
                    color: workspace.modelData.isUrgent ? Theme.dangerColor
                        : workspace.modelData.isActive ? Theme.menuBarTextColor
                        : workspace.modelData.activeWindowId > 0
                            ? Qt.alpha(Theme.menuBarTextColor, 0.65) : Theme.menuBarMutedColor

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.activateWorkspace(workspace.modelData.id)
                }
            }
        }
    }
}
