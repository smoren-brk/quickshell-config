import QtQuick
import "../controlcenter"
import "../../components/theme"
import "../../services"

PillSlider {
    id: root

    required property int monitorId
    required property real brightness

    symbol: Icons.brightness
    value: brightness / 100
    Accessible.name: "Display brightness"
    onMoved: BrightnessService.setBrightness(monitorId, value * 100)
}
