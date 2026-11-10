import QtQuick
import "../../components/theme"
import "../../services"

Row {
    id: root
    required property string outputName
    readonly property var workspaces: NiriService.workspacesForOutput(outputName)
    readonly property var activeWorkspace: workspaces.find(workspace => workspace.isActive)
    spacing: 8
    height: 32

    WorkspaceStrip { outputName: root.outputName }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 100)
        text: root.activeWorkspace ? root.activeWorkspace.name || String(root.activeWorkspace.index) : "—"
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}
