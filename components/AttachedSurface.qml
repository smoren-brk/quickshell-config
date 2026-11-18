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
    readonly property real corner: Math.max(0, Math.min(radius, width / 2, height / 2))

    Shape {
        width: root.width
        height: root.height
        preferredRendererType: Shape.CurveRenderer
        transform: Scale {
            origin.y: root.height / 2
            yScale: root.attachedTop ? -1 : 1
        }
        ShapePath {
            // Leave the attachment edge open: fill closes it implicitly,
            // while the hairline follows only the exposed contour.
            strokeWidth: 1
            strokeColor: Qt.alpha(Theme.surfaceBorderColor, 0.75)
            fillColor: root.color
            startX: -root.corner
            startY: root.height
            PathQuad { x: 0.5; y: root.height - root.corner; controlX: 0.5; controlY: root.height }
            PathLine { x: 0.5; y: root.corner + 0.5 }
            PathQuad { x: root.corner + 0.5; y: 0.5; controlX: 0.5; controlY: 0.5 }
            PathLine { x: root.width - root.corner - 0.5; y: 0.5 }
            PathQuad { x: root.width - 0.5; y: root.corner + 0.5; controlX: root.width - 0.5; controlY: 0.5 }
            PathLine { x: root.width - 0.5; y: root.height - root.corner }
            PathQuad { x: root.width + root.corner; y: root.height; controlX: root.width - 0.5; controlY: root.height }
        }
    }
}
