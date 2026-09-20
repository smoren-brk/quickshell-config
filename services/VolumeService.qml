pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: !!sink && sink.ready && !!sink.audio
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available && sink.audio.muted
    readonly property string deviceName: available ? (sink.description || sink.name) : "No audio output"
    property bool visible: false
    property bool autoHide: false
    property string outputName: ""

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    function showFeedback(): void {
        outputName = NiriService.focusedOutput || Quickshell.screens[0]?.name || "";
        autoHide = true;
        visible = true;
        dismissTimer.restart();
    }

    function hide(): void {
        visible = false;
        dismissTimer.stop();
    }

    function toggleForOutput(name: string): void {
        const wasVisible = visible && outputName === name;
        dismissTimer.stop();
        autoHide = false;
        outputName = name;
        visible = !wasVisible;
    }

    function setVolume(value: real): void {
        if (!available || !Number.isFinite(value))
            return;
        sink.audio.volume = Math.max(0, Math.min(1, value));
        sink.audio.muted = false;
    }

    function adjust(delta: real): void {
        if (available)
            setVolume(volume + delta);
        showFeedback();
    }

    function toggleMute(): void {
        if (available)
            sink.audio.muted = !sink.audio.muted;
    }

    function hold(): void { dismissTimer.stop(); }
    function release(): void { if (visible && autoHide) dismissTimer.restart(); }

    Timer {
        id: dismissTimer
        interval: 2000
        onTriggered: root.visible = false
    }

    IpcHandler {
        target: "volume"
        function raise(): void { root.adjust(0.05); }
        function lower(): void { root.adjust(-0.05); }
        function mute(): void { root.toggleMute(); root.showFeedback(); }
        function show(): void { root.showFeedback(); }
        function hide(): void { root.hide(); }
    }
}
