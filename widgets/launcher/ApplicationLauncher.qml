pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Controls
import "../../components/theme"
import "LauncherSearch.js" as Search

Item {
    id: root

    property bool shown: false
    property real maximumHeight: 560
    property bool browsing: false
    property string selectedResultId: ""
    property bool selectionExplicit: false
    readonly property int selectedIndex: results.findIndex(result => result.id === selectedResultId)
    property alias focusTarget: searchInput
    property real blurScale: 1
    readonly property Region blurRegion: Region {
        item: spotlightBackground
        radius: Math.round(spotlightBackground.radius * root.blurScale)
    }

    readonly property string query: searchInput.text.trim()
    readonly property bool commandMode: query.startsWith(">")
    readonly property string contentQuery: commandMode ? query.slice(1).trim() : query
    readonly property bool showingResults: query.length > 0 || browsing
    readonly property int rowHeight: 56
    readonly property real desiredHeight: 68 + (showingResults ? resultsPanel.height : 28)
    // Retain the visible rows until the window has finished fading out.
    property var results: []
    readonly property var searchResults: {
        if (!shown || !showingResults)
            return [];
        const apps = commandMode ? [] : Search.applications(DesktopEntries.applications.values, query);
        const commands = query ? Search.executables(executableIndex.entries, contentQuery) : [];
        return apps.concat(commands).sort((first, second) => second.score - first.score || (first.kind === second.kind ? 0 : first.kind === "app" ? -1 : 1) || first.name.localeCompare(second.name));
    }
    readonly property string statusText: executableIndex.error || (executableIndex.busy ? "Reading executables…" : commandMode ? "Executables · " + results.length : results.length + " results")

    signal closeRequested

    function select(index: int): void {
        selectionExplicit = true;
        setSelection(index);
    }

    function setSelection(index: int): void {
        selectedResultId = results[index]?.id || "";
        if (applicationList && index >= 0)
            applicationList.positionViewAtIndex(index, ListView.Contain);
    }

    function reconcileSelection(): void {
        const retained = selectionExplicit ? results.findIndex(result => result.id === selectedResultId) : -1;
        setSelection(retained >= 0 ? retained : results.length ? 0 : -1);
    }

    function moveSelection(offset: int): void {
        if (!showingResults) {
            browsing = true;
            return;
        }
        if (results.length)
            select((selectedIndex + offset + results.length) % results.length);
    }

    function activate(index: int): void {
        const result = results[index];
        if (!shown || !result)
            return;
        if (result.kind === "app") {
            result.application.execute();
        } else if (result.kind === "executable") {
            Quickshell.execDetached({
                command: result.command,
                workingDirectory: Quickshell.env("HOME")
            });
        } else {
            return;
        }
        closeRequested();
    }

    onSearchResultsChanged: if (shown)
        results = searchResults
    onResultsChanged: reconcileSelection()
    onQueryChanged: {
        selectionExplicit = false;
        selectedResultId = "";
        reconcileSelection();
        if (applicationList)
            applicationList.positionViewAtBeginning();
    }
    onShownChanged: {
        if (shown) {
            selectionExplicit = false;
            browsing = false;
            searchInput.clear();
            selectedResultId = "";
            results = searchResults;
            reconcileSelection();
        }
    }

    LauncherExecutables {
        id: executableIndex
        active: root.shown
    }

    Rectangle {
        id: spotlightBackground
        anchors.fill: parent
        radius: 16
        color: Theme.spotlightBackgroundColor
        border.color: Theme.spotlightBorderColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 15
            color: "transparent"
            border.color: Qt.alpha("black", 0.18)
        }
    }

    Rectangle {
        id: searchBackground
        width: parent.width
        height: 68
        color: "transparent"

        Text {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: 22
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            text: root.commandMode ? "" : ""
            color: Theme.spotlightSecondaryTextColor
            font.family: Typography.nerdIconFontFamily
            font.pixelSize: 22
        }

        TextInput {
            id: searchInput
            anchors {
                left: searchIcon.right
                right: searchHint.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 16
                rightMargin: 16
            }
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.menuBarTextColor
            selectionColor: Theme.spotlightSelectionColor
            selectedTextColor: Theme.menuBarTextColor
            font.pixelSize: 24
            font.family: Typography.menuBarFontFamily
            selectByMouse: true
            clip: true
            focus: true
            Accessible.name: "Search applications and executables"

            Keys.priority: Keys.BeforeItem
            Keys.onPressed: event => {
                if (preeditText.length > 0)
                    return;
                if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                    root.moveSelection(event.modifiers & Qt.ShiftModifier ? -1 : 1);
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                    root.moveSelection(-1);
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.activate(root.selectedIndex);
                } else if (event.key === Qt.Key_Escape) {
                    root.closeRequested();
                } else {
                    return;
                }
                event.accepted = true;
            }

            onTextChanged: root.browsing = false

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text.length === 0 && searchInput.preeditText.length === 0
                text: "Search apps and commands…"
                color: Theme.spotlightSecondaryTextColor
                font: searchInput.font
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: searchHint
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            width: hintText.implicitWidth + 16
            height: 26
            radius: 5
            color: Theme.menuBarHoverColor

            Text {
                id: hintText
                anchors.centerIn: parent
                text: root.showingResults ? "esc" : "↓ apps"
                color: Theme.spotlightSecondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.showingResults)
                        root.closeRequested();
                    else
                        root.browsing = true;
                    searchInput.forceActiveFocus();
                }
            }
        }
    }

    Text {
        anchors.top: searchBackground.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !root.showingResults
        width: Math.max(0, parent.width - 32)
        horizontalAlignment: Text.AlignHCenter
        text: "↓ browse apps     > executables"
        color: Theme.spotlightSecondaryTextColor
        font.family: Typography.menuBarFontFamily
        font.pixelSize: 11
        elide: Text.ElideRight
    }

    Rectangle {
        id: resultsPanel
        anchors.top: searchBackground.bottom
        anchors.topMargin: 0
        width: parent.width
        height: Math.max(0, Math.min(root.maximumHeight - 68, 54 + Math.max(1, Math.min(7, root.results.length)) * root.rowHeight))
        visible: root.showingResults
        color: "transparent"
        radius: 0
        clip: true

        Behavior on height {
            enabled: root.shown
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: Theme.menuBarBorderColor
        }

        ListView {
            id: applicationList
            anchors {
                fill: parent
                margins: 10
                bottomMargin: 44
            }
            model: root.results
            currentIndex: root.selectedIndex
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            highlightMoveDuration: 100
            highlightResizeDuration: 0
            highlight: Rectangle {
                radius: 7
                color: Theme.spotlightSelectionColor
            }

            delegate: ApplicationResultDelegate {
                required property var modelData
                required property int index
                width: applicationList.width
                height: root.rowHeight
                result: modelData
                selected: ListView.isCurrentItem
                onHoverRequested: root.select(index)
                onLaunchRequested: root.activate(index)
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 4
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: Theme.menuBarSelectedColor
                }
                background: Item {}
            }
        }

        Text {
            anchors.centerIn: applicationList
            width: Math.max(0, applicationList.width - 24)
            visible: root.results.length === 0
            text: executableIndex.busy ? "Reading executables…" : "No matches found"
            horizontalAlignment: Text.AlignHCenter
            color: Theme.spotlightSecondaryTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 34
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            height: 1
            color: Theme.menuBarBorderColor
        }

        Text {
            anchors.left: parent.left
            anchors.right: navigationHint.visible ? navigationHint.left : parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 11
            text: root.statusText
            color: executableIndex.error ? Theme.dangerColor : Theme.spotlightSecondaryTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Text {
            id: navigationHint
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            visible: root.width > 440
            text: "↑ ↓ select    ↵ launch"
            color: Theme.spotlightSecondaryTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 11
        }
    }
}
