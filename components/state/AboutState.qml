pragma Singleton
import Quickshell
import "../../services"

Singleton {
    property bool visible: false
    property string fallbackOutput: ""
    readonly property string outputName: NiriService.focusedOutput || fallbackOutput

    function showForOutput(name: string): void {
        fallbackOutput = name;
        visible = true;
    }

    function hide(): void {
        visible = false;
    }
}
