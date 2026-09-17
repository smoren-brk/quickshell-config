pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var monitors: []
    property string error: ""
    property bool active: false
    property var pending: ({})
    readonly property bool busy: reader.running || setter.running

    function parseInfo(output: string): var {
        const result = [];
        let monitor = null;
        for (const line of output.split("\n")) {
            const display = /^Display (\d+)\s*$/.exec(line);
            const model = /^\s*Model (.+)$/.exec(line);
            const brightness = /^\s*Brightness (\d+)\s*$/.exec(line);
            if (display) {
                monitor = { id: Number(display[1]), name: "Display " + display[1], brightness: 0 };
            } else if (model && monitor) {
                try { monitor.name = JSON.parse(model[1]); }
                catch (_) { monitor.name = model[1]; }
            } else if (brightness && monitor) {
                monitor.brightness = Math.max(0, Math.min(100, Number(brightness[1])));
                result.push(monitor);
                monitor = null;
            }
        }
        return result;
    }

    function refresh(): void {
        if (!busy && Object.keys(pending).length === 0)
            reader.running = true;
    }

    function setBrightness(id: int, value: real): void {
        if (!monitors.some(monitor => monitor.id === id))
            return;
        const next = Object.assign({}, pending);
        next[id] = Math.round(Math.max(0, Math.min(100, value)));
        pending = next;
        writeTimer.restart();
    }

    function writeNext(): void {
        if (busy) {
            writeTimer.restart();
            return;
        }
        const ids = Object.keys(pending);
        if (ids.length === 0) {
            refresh();
            return;
        }
        const id = ids[0];
        const value = pending[id];
        const next = Object.assign({}, pending);
        delete next[id];
        pending = next;
        setter.command = ["raito", "--display", id, "set", String(value)];
        setter.running = true;
    }

    onActiveChanged: if (active) refresh()

    Process {
        id: reader
        command: ["raito", "info"]
        stdout: StdioCollector { id: infoOutput }
        stderr: StdioCollector {}
        onExited: (code, status) => {
            if (code === 0) {
                root.monitors = root.parseInfo(infoOutput.text);
                root.error = root.monitors.length ? "" : "No DDC/CI monitors found";
            } else {
                root.error = "Could not read brightness with raito";
            }
        }
    }

    Process {
        id: setter
        stderr: StdioCollector {}
        onExited: (code, status) => {
            if (code !== 0)
                root.error = "Could not set brightness with raito";
            writeTimer.restart();
        }
    }

    Timer {
        id: writeTimer
        interval: 150
        onTriggered: root.writeNext()
    }
    Timer {
        interval: 5000
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }
}
