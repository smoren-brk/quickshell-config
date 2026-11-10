import Quickshell
import Quickshell.Io
import QtQuick
import "../../components/theme"

Item {
    id: root
    property bool shown: false
    property string mode: "runner"
    property real maximumHeight: 560
    readonly property bool powerMode: mode === "power"
    readonly property real rowHeight: 56
    readonly property real desiredHeight: !powerMode && !searchInput.text.trim() && results.length === 0
        ? ShellMetrics.dockHeight
        : Math.min(maximumHeight, 68 + Math.max(1, Math.min(8, results.length)) * rowHeight)
    property alias focusTarget: searchInput
    property string confirmation: ""
    property string errorMessage: ""
    property var recentIds: []
    readonly property var powerActions: [
        { id: "lock", name: "Lock", subtitle: "Lock this session", glyph: Icons.lock, command: ["loginctl", "lock-session"], confirm: false },
        { id: "sleep", name: "Sleep", subtitle: "Suspend to memory", glyph: Icons.sleep, command: ["systemctl", "suspend"], confirm: false },
        { id: "logout", name: "Log out", subtitle: "End this Niri session", glyph: Icons.logout, command: ["niri", "msg", "action", "quit", "--skip-confirmation"], confirm: true },
        { id: "restart", name: "Restart", subtitle: "Restart the computer", glyph: Icons.restart, command: ["systemctl", "reboot"], confirm: true },
        { id: "shutdown", name: "Shut down", subtitle: "Power off the computer", glyph: Icons.power, command: ["systemctl", "poweroff"], confirm: true }
    ]
    readonly property var results: {
        const query = searchInput.text.trim().toLowerCase();
        if (powerMode)
            return powerActions.filter(action => (action.name + " " + action.id).toLowerCase().includes(query));
        const apps = [...DesktopEntries.applications.values];
        const matches = apps.filter(app => query
            ? [app.name, app.genericName, ...(app.keywords || [])].join(" ").toLowerCase().includes(query)
            : recentIds.includes(app.id));
        return matches.sort((a, b) => {
            if (query) {
                const prefix = Number(b.name.toLowerCase().startsWith(query)) - Number(a.name.toLowerCase().startsWith(query));
                if (prefix) return prefix;
            }
            const ai = recentIds.indexOf(a.id), bi = recentIds.indexOf(b.id);
            return (ai < 0 ? 999 : ai) - (bi < 0 ? 999 : bi) || a.name.localeCompare(b.name);
        });
    }
    signal closeRequested()

    function activate(index: int): void {
        const entry = results[index];
        if (!entry || powerProcess.running) return;
        errorMessage = "";
        if (powerMode) {
            if (entry.confirm && confirmation !== entry.id) {
                confirmation = entry.id;
                return;
            }
            powerProcess.command = entry.command;
            powerProcess.running = true;
        } else {
            recentIds = [entry.id, ...recentIds.filter(id => id !== entry.id)].slice(0, 12);
            entry.execute();
            closeRequested();
        }
    }
    function reset(): void {
        searchInput.clear();
        confirmation = "";
        errorMessage = "";
        resultList.currentIndex = results.length ? 0 : -1;
        resultList.positionViewAtBeginning();
    }
    function moveSelection(step: int): void {
        if (!results.length) return;
        confirmation = "";
        resultList.currentIndex = (resultList.currentIndex + step + results.length) % results.length;
        resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
    }
    onShownChanged: if (shown) reset()
    onModeChanged: reset()
    onResultsChanged: {
        confirmation = "";
        resultList.currentIndex = results.length ? 0 : -1;
        resultList.positionViewAtBeginning();
    }

    Process {
        id: powerProcess
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) root.closeRequested();
            else {
                root.confirmation = "";
                searchInput.clear();
                root.errorMessage = "Action failed. Check session permissions or system logs.";
                console.warn("Power action failed:", stderr.text);
            }
        }
    }

    ListView {
        id: resultList
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
        height: Math.max(0, searchBar.y - 16)
        model: root.results
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: count ? 0 : -1
        delegate: ApplicationResultDelegate {
            required property var modelData
            required property int index
            width: resultList.width
            height: root.rowHeight
            entry: modelData
            selected: ListView.isCurrentItem
            actionLabel: root.powerMode ? (root.confirmation === modelData.id ? "Confirm ↵" : "Select ↵") : "Open ↵"
            onHoverRequested: {
                if (resultList.currentIndex !== index) root.confirmation = "";
                resultList.currentIndex = index;
            }
            onLaunchRequested: {
                resultList.currentIndex = index;
                root.activate(index);
            }
        }
    }
    Text {
        anchors.centerIn: resultList
        visible: root.results.length === 0 && (root.powerMode || searchInput.text.trim().length > 0)
        text: root.powerMode ? "No matching actions" : "No applications found"
        color: Theme.secondaryTextColor
        font.family: Typography.bodyFontFamily
        font.pixelSize: 13
    }
    Item {
        id: searchBar
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 52
        Rectangle { width: parent.width; height: 1; color: Theme.dividerColor }
        Text {
            x: 18
            anchors.verticalCenter: parent.verticalCenter
            text: root.powerMode ? Icons.power : Icons.search
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 20
            color: Theme.mutedTextColor
        }
        TextInput {
            id: searchInput
            anchors { left: parent.left; right: closeButton.left; top: parent.top; bottom: parent.bottom; leftMargin: 48; rightMargin: 8 }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.primaryTextColor
            selectionColor: Theme.textSelectionColor
            selectedTextColor: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 15
            clip: true
            enabled: !powerProcess.running
            Keys.onDownPressed: root.moveSelection(1)
            Keys.onUpPressed: root.moveSelection(-1)
            Keys.onReturnPressed: event => { if (!event.isAutoRepeat) root.activate(resultList.currentIndex); }
            Keys.onEnterPressed: event => { if (!event.isAutoRepeat) root.activate(resultList.currentIndex); }
            Keys.onEscapePressed: {
                if (root.confirmation) root.confirmation = "";
                else root.closeRequested();
            }
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text.length === 0
                text: root.errorMessage || (powerProcess.running ? "Working…" : root.confirmation ? "Press Enter again to confirm · Esc to cancel" : root.powerMode ? "Power and session…" : "Search applications…")
                color: root.errorMessage ? Theme.dangerColor : Theme.mutedTextColor
                font: searchInput.font
                elide: Text.ElideRight
            }
        }
        Text {
            id: closeButton
            anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
            text: "esc"
            color: closeMouse.containsMouse ? Theme.primaryTextColor : Theme.mutedTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 11
            MouseArea {
                id: closeMouse
                anchors.fill: parent
                anchors.margins: -10
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()
            }
        }
    }
}
