import QtQuick
import QtQuick.Controls
import "../../components/theme"

Button {
    id: root

    implicitHeight: 28
    implicitWidth: label.implicitWidth + 24
    padding: 4
    leftPadding: 10
    rightPadding: 10
    hoverEnabled: true
    font.family: Typography.menuBarFontFamily
    font.pixelSize: 12

    contentItem: Text {
        id: label
        text: root.text
        textFormat: Text.PlainText
        font: root.font
        color: Theme.menuBarTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 7
        color: root.down || root.hovered ? Theme.menuBarSelectedColor : Theme.menuBarHoverColor
        border.width: root.visualFocus ? 1 : 0
        border.color: Theme.notificationLabelColor
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
}
