import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/theme"
import "../../services"
import "../brightness"

ColumnLayout {
    id: root
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        StatusCard {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            title: "Wi-Fi"
            status: ConnectivityService.wifiStatus
            symbol: Icons.wifi
            active: ConnectivityService.wifiConnected
        }
        StatusCard {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            title: "Ethernet"
            status: ConnectivityService.ethernetStatus
            symbol: Icons.ethernet
            active: ConnectivityService.ethernetConnected
        }
    }

    StatusCard {
        Layout.fillWidth: true
        implicitHeight: 62
        title: "Bluetooth"
        status: ConnectivityService.bluetoothStatus
        symbol: Icons.bluetooth
        active: ConnectivityService.bluetoothEnabled
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: brightnessPanel.implicitHeight + 24
        radius: 14
        color: Theme.controlCenterCardColor
        border.color: Theme.menuBarBorderColor

        BrightnessPanel {
            id: brightnessPanel
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: soundContent.implicitHeight + 24
        radius: 14
        color: Theme.controlCenterCardColor
        border.color: Theme.menuBarBorderColor

        ColumnLayout {
            id: soundContent
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 10

            Text {
                text: "Sound"
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                PillSlider {
                    Layout.fillWidth: true
                    symbol: VolumeService.muted ? Icons.volumeMuted : Icons.volume
                    muted: VolumeService.muted
                    enabled: VolumeService.available
                    value: VolumeService.volume
                    Accessible.name: "Output volume"
                    // Direct setters do not trigger the keyboard volume HUD.
                    onMoved: {
                        VolumeService.hide();
                        VolumeService.setVolume(value);
                    }
                }

                Button {
                    id: muteButton
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    enabled: VolumeService.available
                    Accessible.name: VolumeService.muted ? "Unmute" : "Mute"
                    onClicked: {
                        VolumeService.hide();
                        VolumeService.toggleMute();
                    }
                    background: Rectangle {
                        radius: height / 2
                        color: muteButton.hovered || muteButton.visualFocus || VolumeService.muted
                            ? Theme.menuBarSelectedColor : Theme.menuBarHoverColor
                        border.width: muteButton.visualFocus ? 1 : 0
                        border.color: Theme.menuBarTextColor
                    }
                    contentItem: Text {
                        text: Icons.volumeMuted
                        color: Theme.menuBarTextColor
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: 15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: VolumeService.muted ? "Unmute" : "Mute"
                }
            }

            Text {
                Layout.fillWidth: true
                visible: !VolumeService.available
                text: "No audio output"
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
            }
        }
    }

    NowPlayingCard { Layout.fillWidth: true }
}
