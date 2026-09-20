pragma Singleton
import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var player: null

    function selectPlayer(started: var): void {
        const playing = players.filter(candidate => candidate.isPlaying);
        if (started && playing.includes(started)) {
            player = started;
        } else if (!playing.includes(player)) {
            player = playing[0] || (players.includes(player) ? player : players[0]) || null;
        }
    }

    onPlayersChanged: selectPlayer(null)
    Component.onCompleted: selectPlayer(null)

    Instantiator {
        model: Mpris.players
        delegate: Connections {
            required property var modelData
            target: modelData
            function onIsPlayingChanged() {
                root.selectPlayer(modelData.isPlaying ? modelData : null);
            }
        }
    }
}
