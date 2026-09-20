pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

Singleton {
    id: root

    property bool visible: false
    property string outputName: ""

    onVisibleChanged: {
        BrightnessService.active = visible;
        if (visible) {
            VolumeService.hide();
            LauncherState.visible = false;
        }
    }

    function open(): void {
        outputName = NiriService.focusedOutput || Quickshell.screens[0]?.name || "";
        visible = true;
    }

    function toggleForOutput(name: string): void {
        const wasVisible = visible && outputName === name;
        outputName = name;
        visible = !wasVisible;
    }

    Connections {
        target: LauncherState
        function onVisibleChanged() {
            if (LauncherState.visible)
                root.visible = false;
        }
    }

    IpcHandler {
        target: "controlCenter"
        function toggle(): void { if (root.visible) root.visible = false; else root.open(); }
        function open(): void { root.open(); }
        function close(): void { root.visible = false; }
    }
}
