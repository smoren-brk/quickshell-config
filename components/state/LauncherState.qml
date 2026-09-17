pragma Singleton
import Quickshell
import Quickshell.Io
import "../../services"

Singleton {
    id: root
    property bool visible: false
    property string outputName: ""

    function show(): void {
        outputName = NiriService.focusedOutput || Quickshell.screens[0]?.name || "";
        visible = true;
    }
    function toggleForOutput(name: string): void {
        const wasVisible = visible && outputName === name;
        outputName = name;
        visible = !wasVisible;
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { if (root.visible) root.visible = false; else root.show(); }
        function show(): void { root.show(); }
        function hide(): void { root.visible = false; }
        function setVisible(visible: bool): void { if (visible) root.show(); else root.visible = false; }
        function getVisible(): bool { return root.visible; }
    }
}
