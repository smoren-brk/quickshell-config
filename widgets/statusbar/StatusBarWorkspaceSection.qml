import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName

    implicitWidth: content.width
    implicitHeight: 26

    Row {
        id: content

        height: parent.height
        spacing: 8

        WorkspaceStrip {
            outputName: root.outputName
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            width: Math.min(implicitWidth, 200)
            elide: Text.ElideRight
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            text: NiriService.activeAppName
            visible: text.length > 0
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
        }
    }
}
