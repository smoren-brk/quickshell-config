import QtQuick
import QtQuick.Layouts
import "../../components/theme"

Rectangle {
    id: root

    required property string title
    required property string status
    required property string symbol
    property bool active: false

    implicitHeight: 72
    radius: 14
    color: Theme.controlCenterCardColor
    border.color: Theme.menuBarBorderColor
    Accessible.role: Accessible.StaticText
    Accessible.name: title + ": " + status

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: root.active ? Theme.spotlightSelectionColor : Theme.menuBarHoverColor
            Text {
                anchors.centerIn: parent
                text: root.symbol
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 17
                color: Theme.menuBarTextColor
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.status
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
