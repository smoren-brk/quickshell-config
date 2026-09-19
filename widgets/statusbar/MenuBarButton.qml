import QtQuick
import "../../components/theme"

Rectangle {
    id: root

    property string text: ""
    property string fontFamily: Typography.nerdIconFontFamily
    property int fontSize: 16
    property bool selected: false
    signal clicked()

    implicitWidth: Math.max(30, label.implicitWidth + 16)
    implicitHeight: 26
    radius: 5
    color: selected ? Theme.menuBarSelectedColor
        : mouse.containsMouse ? Theme.menuBarHoverColor : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.menuBarTextColor
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
