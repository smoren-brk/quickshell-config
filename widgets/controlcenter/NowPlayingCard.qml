import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../components/theme"
import "../../services"

Rectangle {
    id: root

    property var player: MediaService.player
    readonly property string title: player ? (player.trackTitle || player.identity || "Now Playing") : "Not Playing"
    readonly property string details: player
        ? ([player.trackArtist, player.trackAlbum].filter(value => !!value).join(" — ") || player.identity) : ""

    implicitHeight: 72
    radius: 14
    color: Theme.controlCenterCardColor
    border.color: Theme.menuBarBorderColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        ClippingRectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 6
            color: Theme.menuBarHoverColor

            Text {
                anchors.centerIn: parent
                visible: artwork.status !== Image.Ready
                text: Icons.music
                color: Theme.menuBarTextColor
                font.family: Typography.nerdIconFontFamily
                font.pixelSize: 22
            }
            Image {
                id: artwork
                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
                sourceSize.width: 88
                sourceSize.height: 88
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
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
                visible: text !== ""
                text: root.details
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        RowLayout {
            spacing: 2
            MediaButton {
                symbol: root.player && root.player.isPlaying ? Icons.pause : Icons.play
                label: root.player && root.player.isPlaying ? "Pause" : "Play"
                enabled: !!root.player && root.player.canControl && root.player.canTogglePlaying
                onClicked: if (enabled) root.player.togglePlaying()
            }
            MediaButton {
                symbol: Icons.nextTrack
                label: "Next track"
                enabled: !!root.player && root.player.canControl && root.player.canGoNext
                onClicked: if (enabled) root.player.next()
            }
        }
    }
}
