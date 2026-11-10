import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root
    required property string outputName
    readonly property var workspaces: NiriService.workspacesForOutput(outputName)
    implicitWidth: dots.width
    implicitHeight: 32

    Row {
        id: dots
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1
        Repeater {
            model: root.workspaces
            Item {
                id: dot
                required property var modelData
                width: modelData.isActive ? 26 : 18
                height: 32
                Behavior on width { NumberAnimation { duration: 155; easing.type: Easing.OutCubic } }
                Rectangle {
                    anchors.centerIn: parent
                    width: dot.modelData.isActive ? 18 : 5
                    height: 5
                    radius: 2.5
                    color: dot.modelData.isUrgent ? Theme.dangerColor
                        : dot.modelData.isActive ? Theme.accentColor
                        : dot.modelData.activeWindowId > 0 ? Theme.secondaryTextColor : Theme.mutedTextColor
                    opacity: dot.modelData.isActive || dot.modelData.activeWindowId > 0 ? 1 : 0.45
                    Behavior on width { NumberAnimation { duration: 155; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 155 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.activateWorkspace(dot.modelData.id)
                }
            }
        }
    }
}
