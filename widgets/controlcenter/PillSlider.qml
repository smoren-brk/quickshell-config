import QtQuick
import QtQuick.Controls
import "../../components/theme"

Slider {
    id: root

    property string symbol: ""
    property bool muted: false

    implicitWidth: 240
    implicitHeight: 28
    padding: 0
    from: 0
    to: 1
    stepSize: 0.01
    opacity: enabled ? 1 : 0.4

    background: Rectangle {
        width: root.width
        height: root.height
        radius: height / 2
        color: Qt.alpha(Theme.mochaSurface2, 0.35)
        border.width: root.visualFocus ? 1 : 0
        border.color: Theme.menuBarTextColor

        Rectangle {
            width: thumb.x + thumb.width
            height: parent.height
            radius: parent.radius
            color: root.muted ? Theme.mochaOverlay1 : Theme.accentColor
        }
    }

    handle: Rectangle {
        id: thumb
        x: root.visualPosition * (root.width - width)
        width: root.height
        height: root.height
        radius: height / 2
        color: Theme.mochaText
        border.color: Qt.alpha(Theme.mochaBase, 0.12)
    }

    Text {
        x: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.symbol
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 14
        color: Theme.mochaBase
    }
}
