import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    implicitWidth: 200
    implicitHeight: 200
    radius: 20
    color: Theme.shellBackgroundColor
    readonly property color ink: Theme.menuBarTextColor
    readonly property bool silent: VolumeService.muted || VolumeService.volume === 0
    readonly property real level: VolumeService.available && !VolumeService.muted
        ? Math.max(0, Math.min(1, VolumeService.volume)) : 0

    Button {
        id: speaker
        x: (parent.width - width) / 2
        y: 45
        width: 112
        height: 88
        enabled: VolumeService.available
        Accessible.name: VolumeService.muted ? "Unmute" : "Mute"
        onClicked: VolumeService.toggleMute()
        background: Rectangle {
            color: "transparent"
            radius: 12
            border.width: speaker.visualFocus ? 1 : 0
            border.color: root.ink
        }
        contentItem: Item {
            opacity: speaker.enabled ? 1 : 0.4

            Shape {
                anchors.centerIn: parent
                width: 160
                height: 128
                scale: 0.625

                ShapePath {
                    strokeWidth: 0
                    fillColor: root.ink
                    PathSvg {
                        path: "M 9 43 L 31 43 L 55 23 Q 60 19 60 25 L 60 103 Q 60 109 55 105 L 31 85 L 9 85 Q 2 85 2 78 L 2 50 Q 2 43 9 43 Z"
                    }
                }
                ShapePath {
                    strokeColor: root.silent ? "transparent" : root.ink
                    strokeWidth: 7
                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    PathSvg { path: "M 87 40 Q 106 64 87 88 M 111 25 Q 142 64 111 103 M 135 10 Q 176 64 135 118" }
                }
                ShapePath {
                    strokeColor: VolumeService.muted ? root.ink : "transparent"
                    strokeWidth: 7
                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    PathSvg { path: "M 94 47 L 128 81 M 128 47 L 94 81" }
                }
            }
        }
    }

    Slider {
        id: meter
        x: 20
        y: parent.height - 36
        width: parent.width - 40
        height: 24
        padding: 0
        from: 0
        to: 1
        stepSize: 0.01
        value: VolumeService.volume
        enabled: VolumeService.available
        Accessible.name: "Output volume"
        onMoved: VolumeService.setVolume(value)

        background: Rectangle {
            y: (meter.height - height) / 2
            width: meter.width
            height: 10
            color: Qt.alpha(root.ink, 0.14)
            border.width: meter.visualFocus ? 1 : 0
            border.color: "white"

            Row {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 1
                Repeater {
                    model: 16
                    Item {
                        required property int index
                        width: (meter.width - 17) / 16
                        height: 8
                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, root.level * 16 - index))
                            height: parent.height
                            color: "#ffffff"
                        }
                    }
                }
            }
        }
        handle: Item {}
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 142
        visible: !VolumeService.available
        text: "No audio output"
        font.family: Typography.bodyFontFamily
        font.pixelSize: 13
        color: root.ink
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered) VolumeService.hold();
            else VolumeService.release();
        }
    }
}
