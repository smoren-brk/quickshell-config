import QtQuick
import QtQuick.Shapes
import "theme"

// Rounded free edge, concave corners where the surface meets its parent.
// The joins extend one radius beyond either side; allow room in panel windows.
Item {
    id: root
    property real radius: 12
    property bool attachedTop: false
    property color color: Theme.shellBackgroundColor

    Shape {
        width: root.width
        height: root.height
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            origin.y: root.height / 2
            yScale: root.attachedTop ? -1 : 1
        }
        ShapePath {
            strokeWidth: -1
            fillColor: root.color
            PathSvg {
                path: {
                    const w = root.width, h = root.height;
                    const r = Math.max(0, Math.min(root.radius, w / 2, h / 2));
                    return `M ${r} 0 H ${w-r} Q ${w} 0 ${w} ${r}
                        V ${h-r} Q ${w} ${h} ${w+r} ${h}
                        H ${-r} Q 0 ${h} 0 ${h-r}
                        V ${r} Q 0 0 ${r} 0 Z`;
                }
            }
        }
    }
}
