pragma Singleton
import QtQuick
import Quickshell
import Niri

Singleton {
    id: root

    property var workspaces: []
    property bool connected: false
    readonly property string focusedOutput: workspaces.find(workspace => workspace.isFocused)?.output || ""

    function workspacesForOutput(name: string): var {
        return workspaces.filter(workspace => workspace.output === name)
            .sort((left, right) => left.index - right.index);
    }

    // Model.get() returns snapshots; refresh on role changes as well as row changes.
    function refreshWorkspaces(): void {
        const result = [];
        if (connected) {
            for (let row = 0; row < niri.workspaces.count; row++)
                result.push(niri.workspaces.get(row));
        }
        workspaces = result;
    }

    function activateWorkspace(id: real): void {
        const result = niri.focusWorkspaceById(id);
        if (!result.ok)
            console.warn("Could not activate Niri workspace:", result.error);
    }

    // Shared connection, following imiric/quickshell-niri's service pattern.
    Niri {
        id: niri
        Component.onCompleted: {
            if (Quickshell.env("NIRI_SOCKET"))
                connect();
        }
        onConnected: {
            root.connected = true;
            root.refreshWorkspaces();
        }
        onDisconnected: {
            root.connected = false;
            root.workspaces = [];
        }
        onErrorOccurred: error => console.warn("Niri connection error:", error)
    }

    Connections {
        target: niri.workspaces
        function onDataChanged() { root.refreshWorkspaces(); }
        function onModelReset() { root.refreshWorkspaces(); }
        function onRowsInserted() { root.refreshWorkspaces(); }
        function onRowsRemoved() { root.refreshWorkspaces(); }
        function onRowsMoved() { root.refreshWorkspaces(); }
        function onLayoutChanged() { root.refreshWorkspaces(); }
    }

    Timer {
        interval: 1000
        repeat: true
        running: !!Quickshell.env("NIRI_SOCKET") && !root.connected
        onTriggered: niri.connect()
    }
}
