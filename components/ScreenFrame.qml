import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "theme"

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Decorative, click-through layer; compositor blur is disabled in Niri.
    WlrLayershell.namespace: "wisp-frame"
    mask: Region {}

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: -1
            fillColor: Theme.shellBackgroundColor
            fillRule: ShapePath.OddEvenFill
            PathSvg {
                path: {
                    const w = root.width, h = root.height;
                    const b = ShellMetrics.borderWidth, r = ShellMetrics.screenRadius;
                    // A rounded desktop cutout leaves the rounding facing inward.
                    return `M 0 0 H ${w} V ${h} H 0 Z
                        M ${b+r} ${b} H ${w-b-r}
                        A ${r} ${r} 0 0 1 ${w-b} ${b+r}
                        V ${h-b-r} A ${r} ${r} 0 0 1 ${w-b-r} ${h-b}
                        H ${b+r} A ${r} ${r} 0 0 1 ${b} ${h-b-r}
                        V ${b+r} A ${r} ${r} 0 0 1 ${b+r} ${b} Z`;
                }
            }
        }
    }
}
