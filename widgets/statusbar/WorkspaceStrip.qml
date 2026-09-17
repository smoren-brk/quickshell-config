import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName

    readonly property var workspaces: NiriService.workspacesForOutput(outputName)
    readonly property int activePosition: {
        const position = workspaces.findIndex(workspace => workspace.isActive);
        return Math.max(0, position);
    }
    property int previousActivePosition: activePosition
    property real starRotation: 0
    readonly property real activeWorkspaceId: workspaces.find(workspace => workspace.isActive)?.id ?? -1

    onActiveWorkspaceIdChanged: {
        if (activeWorkspaceId >= 0)
            shimmerAnimation.restart();
    }

    implicitWidth: workspaceRow.width + 8
    implicitHeight: 32

    onActivePositionChanged: {
        const direction = activePosition >= previousActivePosition ? 1 : -1;
        starRotation += direction * 180;
        previousActivePosition = activePosition;
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.panelSurfaceColor
    }

    Canvas {
        id: trail
        anchors.fill: parent
        clip: true

        property var motes: []
        property real previousX: 0
        readonly property int lifetime: 380

        function record(x: real) {
            const now = Date.now();
            const steps = Math.max(1, Math.ceil(Math.abs(x - previousX) / 3));
            for (let step = 1; step <= steps; step++) {
                motes.push({
                    x: previousX + (x - previousX) * step / steps + highlight.width / 2,
                    born: now,
                    phase: Math.random() * Math.PI * 2
                });
            }
            motes = motes.slice(-160);
            previousX = x;
            fadeTimer.start();
            requestPaint();
        }

        onPaint: {
            const context = getContext("2d");
            context.clearRect(0, 0, width, height);
            const now = Date.now();
            for (const mote of motes) {
                const age = (now - mote.born) / lifetime;
                if (age >= 1)
                    continue;
                const fade = Math.pow(1 - age, 2);
                const y = height / 2;
                context.globalAlpha = fade * 0.12;
                context.fillStyle = Theme.accentHoverColor;
                context.beginPath();
                context.arc(mote.x, y, 3 + 7 * (1 - age), 0, Math.PI * 2);
                context.fill();

                const sparkle = 0.5 + 0.5 * Math.sin(age * Math.PI * 6 + mote.phase);
                context.globalAlpha = fade * sparkle * 0.8;
                context.fillStyle = "white";
                context.fillRect(mote.x - 0.7, y + Math.sin(mote.phase) * 7 - 0.7, 1.4, 1.4);
            }
            context.globalAlpha = 1;
        }

        Timer {
            id: fadeTimer
            interval: 16
            repeat: true
            onTriggered: {
                const now = Date.now();
                trail.motes = trail.motes.filter(mote => now - mote.born < trail.lifetime);
                trail.requestPaint();
                if (trail.motes.length === 0)
                    stop();
            }
        }
    }

    Rectangle {
        id: highlight
        visible: root.activeWorkspaceId >= 0

        x: workspaceRow.x + root.activePosition * (26 + workspaceRow.spacing)
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: height / 2
        color: Theme.accentHoverColor

        onXChanged: {
            if (slideAnimation.running)
                trail.record(x);
        }

        Canvas {
            id: shimmer
            anchors.fill: parent
            property real progress: 1

            onProgressChanged: requestPaint()
            onPaint: {
                const context = getContext("2d");
                context.clearRect(0, 0, width, height);
                if (progress <= 0 || progress >= 1)
                    return;

                const center = -width + progress * width * 3;
                const band = width * 0.55;
                const gradient = context.createLinearGradient(center - band, 0, center + band, height);
                gradient.addColorStop(0, "transparent");
                gradient.addColorStop(0.5, "rgba(255, 255, 255, 0.6)");
                gradient.addColorStop(1, "transparent");

                context.save();
                context.beginPath();
                context.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2);
                context.clip();
                context.fillStyle = gradient;
                context.fillRect(0, 0, width, height);
                context.restore();
            }

            NumberAnimation {
                id: shimmerAnimation
                target: shimmer
                property: "progress"
                from: 0
                to: 1
                duration: 550
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            anchors.centerIn: parent
            text: Icons.activeWorkspace
            color: Theme.accentTextColor
            font.family: Typography.symbolIconFontFamily
            font.pixelSize: 18
            rotation: root.starRotation

            Behavior on rotation {
                NumberAnimation {
                    duration: 700
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on x {
            NumberAnimation {
                id: slideAnimation
                duration: 250
                easing.type: Easing.OutCubic
                onRunningChanged: {
                    if (running)
                        trail.previousX = highlight.x;
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: workspaceRow
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            id: workspaceRepeater
            model: root.workspaces

            Item {
                id: delegate

                required property var modelData

                width: 26
                height: 26

                Text {
                    anchors.centerIn: parent
                    visible: !delegate.modelData.isActive
                    text: Icons.inactiveWorkspace
                    color: delegate.modelData.isUrgent
                            ? Theme.dangerColor
                            : delegate.modelData.activeWindowId > 0
                                ? Theme.accentHoverColor
                                : Theme.mutedTextColor
                    font.family: Typography.symbolIconFontFamily
                    font.pixelSize: 18
                    scale: 0.6

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NiriService.activateWorkspace(delegate.modelData.id)
                }
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}
