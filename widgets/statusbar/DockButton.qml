import QtQuick
import QtQuick.Controls
import "../../components/theme"

Rectangle {
    id: root
    property string glyph
    property string label
    property bool active: false
    signal clicked()
    width: 32
    height: 36
    radius: 6
    color: active || mouse.containsMouse ? Theme.selectedSurfaceColor : "transparent"
    Behavior on color { ColorAnimation { duration: 110 } }
    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? Theme.accentColor : Theme.secondaryTextColor
        font.family: Typography.nerdIconFontFamily
        font.pixelSize: 19
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    ToolTip.visible: mouse.containsMouse && label.length > 0
    ToolTip.delay: 600
    ToolTip.text: label
}
