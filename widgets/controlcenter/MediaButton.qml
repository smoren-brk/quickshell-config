import QtQuick
import QtQuick.Controls
import "../../components/theme"

Button {
    id: root

    required property string symbol
    required property string label

    implicitWidth: 28
    implicitHeight: 32
    Accessible.name: label
    ToolTip.visible: hovered
    ToolTip.text: label

    background: Rectangle {
        radius: 7
        color: root.hovered || root.visualFocus ? Theme.menuBarHoverColor : "transparent"
        border.width: root.visualFocus ? 1 : 0
        border.color: Theme.menuBarTextColor
    }
    contentItem: Text {
        text: root.symbol
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 16
        color: root.enabled ? Theme.menuBarTextColor : Theme.menuBarMutedColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
