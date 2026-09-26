import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../components/theme"

PanelWindow {
    id: root

    required property var targetScreen
    property bool opened: false
    property bool queried: false
    property int selectedTab: 0
    property var system: ({})
    property string error: ""
    signal dismissed()

    readonly property var tabs: ["Overview", "Displays", "Storage"]
    readonly property var displays: system.Display || []
    readonly property var disks: system.Disk || []
    readonly property var gpus: system.GPU || []
    readonly property var os: system.OS || ({})
    readonly property var cpu: system.CPU || ({})
    readonly property var memory: system.Memory || ({})
    readonly property var packages: system.Packages || ({})
    readonly property var host: system.Host || ({})
    readonly property var kernel: system.Kernel || ({})
    readonly property var uptime: system.Uptime || ({})

    function readModules(output) {
        const modules = {};
        const entries = JSON.parse(output);
        for (const entry of entries) {
            if (entry.result !== undefined)
                modules[entry.type] = entry.result;
        }
        return modules;
    }

    function gib(bytes) {
        return Number.isFinite(bytes) ? (bytes / 1073741824).toFixed(1) + " GiB" : "Unknown";
    }

    function duration(milliseconds) {
        if (!Number.isFinite(milliseconds))
            return "Unknown";
        const minutes = Math.floor(milliseconds / 60000);
        const days = Math.floor(minutes / 1440);
        const hours = Math.floor((minutes % 1440) / 60);
        return (days ? days + "d " : "") + hours + "h " + (minutes % 60) + "m";
    }

    onOpenedChanged: {
        if (opened) {
            selectedTab = 0;
            if (!queried) {
                queried = true;
                systemReader.running = true;
            }
        }
    }
    onBackingWindowVisibleChanged: if (backingWindowVisible)
        Qt.callLater(() => panel.forceActiveFocus())

    Process {
        id: systemReader
        command: ["fastfetch", "--json"]
        stdout: StdioCollector { id: systemOutput }
        stderr: StdioCollector {}
        onExited: code => {
            if (code !== 0) {
                root.error = "Could not read system information from fastfetch.";
                return;
            }
            try {
                root.system = root.readModules(systemOutput.text);
                root.error = "";
            } catch (_) {
                root.error = "Could not parse fastfetch output.";
            }
        }
    }

    screen: targetScreen
    visible: opened
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qqq-about-nixos"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    BackgroundEffect.blurRegion: Region { item: panel; radius: panel.radius }

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
        onWheel: event => { event.accepted = true; }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(860, root.width - 32)
        height: Math.min(520, root.height - 32)
        radius: 15
        color: Theme.menuBarBackgroundColor
        border.color: Theme.spotlightBorderColor
        focus: root.opened
        clip: true
        Keys.onEscapePressed: root.dismissed()

        MouseArea {
            anchors.fill: parent
            onWheel: event => { event.accepted = true; }
        }

        Item {
            id: titleBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 54

            Rectangle {
                anchors.centerIn: parent
                width: tabRow.implicitWidth + 8
                height: 32
                radius: 8
                color: Theme.menuBarHoverColor
                border.color: Theme.menuBarBorderColor

                Row {
                    id: tabRow
                    anchors.centerIn: parent
                    spacing: 2
                    Repeater {
                        model: root.tabs
                        delegate: Rectangle {
                            required property int index
                            required property string modelData
                            width: tabText.implicitWidth + 24
                            height: 26
                            radius: 6
                            color: root.selectedTab === index ? Theme.menuBarSelectedColor : tabMouse.containsMouse ? Theme.menuBarHoverColor : "transparent"
                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData
                                color: root.selectedTab === index ? Theme.menuBarTextColor : Theme.secondaryTextColor
                                font.family: Typography.menuBarFontFamily
                                font.pixelSize: 13
                                font.weight: root.selectedTab === index ? Font.DemiBold : Font.Normal
                            }
                            MouseArea {
                                id: tabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedTab = index
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: Theme.menuBarBorderColor
            }
        }

        Item {
            id: content
            anchors { top: titleBar.bottom; bottom: footer.top; left: parent.left; right: parent.right }

            Row {
                anchors.centerIn: parent
                width: Math.min(parent.width - 60, 750)
                spacing: 45
                visible: root.selectedTab === 0

                Item {
                    id: logo
                    width: Math.min(235, (parent.width - 45) * 0.36)
                    height: width
                    Text {
                        anchors.centerIn: parent
                        text: Icons.nixos
                        color: Theme.mochaBlue
                        font.family: Typography.nerdIconFontFamily
                        font.pixelSize: parent.width * 0.75
                    }
                }

                Column {
                    width: parent.width - logo.width - parent.spacing
                    spacing: 5

                    Text {
                        text: "NixOS"
                        color: Theme.menuBarTextColor
                        font.family: Typography.menuBarFontFamily
                        font.pixelSize: 35
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: root.os.prettyName || "Loading system information…"
                        color: Theme.secondaryTextColor
                        font.family: Typography.menuBarFontFamily
                        font.pixelSize: 14
                    }
                    Item { width: 1; height: 16 }
                    InfoRow { label: "Computer"; value: (root.host.vendor || "") + " " + (root.host.name || "Unknown") }
                    InfoRow { label: "Processor"; value: root.cpu.cpu || "Unknown" }
                    InfoRow { label: "Graphics"; value: root.gpus.map(gpu => gpu.name).join(", ") || "Unknown" }
                    InfoRow { label: "Memory"; value: root.gib(root.memory.total) }
                    InfoRow { label: "Packages"; value: root.packages.all !== undefined ? String(root.packages.all) : "Unknown" }
                    InfoRow { label: "Kernel"; value: root.kernel.release || "Unknown" }
                    InfoRow { label: "Uptime"; value: root.duration(root.uptime.uptime) }
                }
            }

            Flickable {
                anchors { fill: parent; margins: 32 }
                contentWidth: width
                contentHeight: displayColumn.implicitHeight
                clip: true
                visible: root.selectedTab === 1

                Column {
                    id: displayColumn
                    width: parent.width
                    spacing: 14
                    SectionTitle { text: "Connected displays" }
                    Text {
                        visible: root.displays.length === 0
                        text: "No displays reported by fastfetch."
                        color: Theme.secondaryTextColor
                        font.family: Typography.menuBarFontFamily
                    }
                    Repeater {
                        model: root.displays
                        delegate: DetailCard {
                            required property var modelData
                            title: modelData.name || "Display"
                            subtitle: modelData.output ? modelData.output.width + " × " + modelData.output.height
                                + "  ·  " + Number(modelData.output.refreshRate).toFixed(0) + " Hz" : "Unknown resolution"
                            detail: [modelData.type, modelData.physical ? modelData.physical.width + " × " + modelData.physical.height + " mm" : "", modelData.hdrStatus === "Supported" ? "HDR supported" : ""].filter(Boolean).join("  ·  ")
                        }
                    }
                }
            }

            Flickable {
                anchors { fill: parent; margins: 32 }
                contentWidth: width
                contentHeight: storageColumn.implicitHeight
                clip: true
                visible: root.selectedTab === 2

                Column {
                    id: storageColumn
                    width: parent.width
                    spacing: 14
                    SectionTitle { text: "Mounted storage" }
                    Text {
                        visible: root.disks.length === 0
                        text: "No mounted storage reported by fastfetch."
                        color: Theme.secondaryTextColor
                        font.family: Typography.menuBarFontFamily
                    }
                    Repeater {
                        model: root.disks
                        delegate: DetailCard {
                            required property var modelData
                            title: (modelData.name || modelData.mountFrom || "Disk") + "  ·  " + modelData.mountpoint
                            subtitle: modelData.bytes ? root.gib(modelData.bytes.used) + " used of " + root.gib(modelData.bytes.total) : "Capacity unknown"
                            detail: [modelData.filesystem, modelData.mountFrom, (modelData.volumeType || []).join(", ")].filter(Boolean).join("  ·  ")
                            progress: modelData.bytes && modelData.bytes.total ? modelData.bytes.used / modelData.bytes.total : 0
                            showProgress: true
                        }
                    }
                }
            }

        }

        Item {
            id: footer
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 51
            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.menuBarBorderColor }
            Text {
                anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                text: root.error || (root.os.buildID ? "Build " + root.os.buildID : "System information from fastfetch")
                color: root.error ? Theme.dangerColor : Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
                width: parent.width - 150
            }
            Rectangle {
                anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                width: 92; height: 29; radius: 7
                color: closeMouse.containsMouse ? Theme.menuBarSelectedColor : Theme.menuBarHoverColor
                border.color: Theme.menuBarBorderColor
                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    color: Theme.menuBarTextColor
                    font.family: Typography.menuBarFontFamily
                    font.pixelSize: 12
                }
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismissed()
                }
            }
        }
    }

    component SectionTitle: Text {
        color: Theme.menuBarTextColor
        font.family: Typography.menuBarFontFamily
        font.pixelSize: 21
        font.weight: Font.DemiBold
    }

    component InfoRow: Item {
        property string label: ""
        property string value: ""
        width: parent.width
        height: Math.max(labelText.implicitHeight, valueText.implicitHeight) + 6
        Text {
            id: labelText
            width: 105
            text: label
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Text {
            id: valueText
            x: 112
            width: parent.width - x
            text: value
            color: Theme.menuBarTextColor
            elide: Text.ElideRight
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 13
        }
    }

    component DetailCard: Rectangle {
        id: card
        property string title: ""
        property string subtitle: ""
        property string detail: ""
        property real progress: 0
        property bool showProgress: false
        width: parent.width
        height: showProgress ? 112 : 90
        radius: 11
        color: Theme.panelSurfaceColor
        border.color: Theme.menuBarBorderColor
        Column {
            anchors { fill: parent; margins: 17 }
            spacing: 6
            Text {
                text: card.title
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Text {
                text: card.subtitle
                color: Theme.menuBarTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 13
            }
            Text {
                text: card.detail
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
            }
            Rectangle {
                visible: card.showProgress
                width: parent.width
                height: 5
                radius: 3
                color: Theme.menuBarHoverColor
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, card.progress))
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accentColor
                }
            }
        }
    }
}
