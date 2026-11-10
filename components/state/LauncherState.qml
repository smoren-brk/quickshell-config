pragma Singleton
import Quickshell
import Quickshell.Io
import "../../services"

Singleton {
    id: root
    property bool visible: false
    property string outputName: ""
    property string mode: "runner"
    property bool barPinned: false
    property var revealedOutputs: ({})
    readonly property bool barVisible: barPinned || Object.values(revealedOutputs).some(value => value)
    signal barHideRequested()

    function reportBarVisibility(name: string, revealed: bool): void {
        if (revealedOutputs[name] !== revealed)
            revealedOutputs = Object.assign({}, revealedOutputs, { [name]: revealed });
    }

    function show(): void {
        showMode("runner");
    }

    function showMode(nextMode: string): void {
        outputName = NiriService.focusedOutput || Quickshell.screens[0]?.name || "";
        mode = nextMode;
        visible = true;
    }
    function toggleForOutput(name: string, nextMode: string): void {
        const wasVisible = visible && outputName === name && mode === nextMode;
        outputName = name;
        mode = nextMode;
        visible = !wasVisible;
    }

    function showPower(): void {
        showMode("power");
    }

    function hideBar(): void {
        barPinned = false;
        visible = false;
        barHideRequested();
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { if (root.visible && root.mode === "runner") root.visible = false; else root.show(); }
        function show(): void { root.show(); }
        function hide(): void { root.visible = false; }
        function setVisible(visible: bool): void { if (visible) root.show(); else root.visible = false; }
        function getVisible(): bool { return root.visible; }
    }

    IpcHandler {
        target: "power"
        function show(): void { root.showPower(); }
        function hide(): void { if (root.mode === "power") root.visible = false; }
        function toggle(): void { if (root.visible && root.mode === "power") root.visible = false; else root.showPower(); }
    }

    IpcHandler {
        target: "bar"
        function show(): void { root.barPinned = true; }
        function hide(): void { root.hideBar(); }
        function toggle(): void { if (root.barVisible) root.hideBar(); else root.barPinned = true; }
        function getVisible(): bool { return root.barVisible; }
    }
}
