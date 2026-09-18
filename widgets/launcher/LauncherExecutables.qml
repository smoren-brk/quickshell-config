import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property bool active: false
    property var entries: []
    property string error: ""
    readonly property bool busy: reader.running

    onActiveChanged: if (active && !reader.running)
        reader.running = true
    Component.onCompleted: if (active)
        reader.running = true

    Process {
        id: reader
        command: ["python3", decodeURIComponent(Qt.resolvedUrl("list-executables.py").toString().replace(/^file:\/\//, ""))]
        workingDirectory: Quickshell.env("HOME")
        stdout: StdioCollector {
            id: output
        }
        stderr: StdioCollector {}
        onExited: code => {
            if (code !== 0) {
                root.error = "Could not read executables from PATH";
                return;
            }
            try {
                root.entries = JSON.parse(output.text);
                root.error = "";
            } catch (_) {
                root.error = "Could not read executable list";
            }
        }
    }
}
