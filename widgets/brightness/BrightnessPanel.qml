import QtQuick
import QtQuick.Layouts
import "../../components/theme"
import "../../services"

ColumnLayout {
    id: root
    spacing: 14

    Text {
        text: "Brightness"
        color: Theme.primaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 18
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
                color: Theme.primaryTextColor
                font.family: Typography.bodyFontFamily
                font.pixelSize: 14
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
        font.family: Typography.bodyFontFamily
        font.pixelSize: 13
        wrapMode: Text.Wrap
    }
}
