import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

ColumnLayout {
    id: root
    spacing: 10

    Text {
        text: "Display"
        color: Theme.menuBarTextColor
        font.family: Typography.menuBarFontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    Repeater {
        model: BrightnessService.monitors
        ColumnLayout {
            required property var modelData
            Layout.fillWidth: true
            spacing: 6
            Text {
                Layout.fillWidth: true
                text: modelData.name
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
            BrightnessSlider {
                Layout.fillWidth: true
                monitorId: modelData.id
                brightness: modelData.brightness
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: BrightnessService.error !== "" || BrightnessService.monitors.length === 0
        text: BrightnessService.error || "Reading monitors…"
        color: Theme.secondaryTextColor
        font.family: Typography.menuBarFontFamily
        font.pixelSize: 13
        wrapMode: Text.Wrap
    }
}
