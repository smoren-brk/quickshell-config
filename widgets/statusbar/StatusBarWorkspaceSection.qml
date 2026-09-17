import QtQuick
import "../../components/theme"
import "../../services"

Item {
    id: root

    required property string outputName

    readonly property var outputWorkspaces: NiriService.workspacesForOutput(outputName)
    readonly property var activeWorkspace: outputWorkspaces
        .find(workspace => workspace.isActive)

    function japaneseNumber(value: int): string {
        const digits = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"];
        if (value === 0)
            return digits[0];
        if (value < 0 || value >= 10000)
            return value.toString().split("").map(c => digits[Number(c)] ?? c).join("");

        let result = "";
        const units = [[1000, "千"], [100, "百"], [10, "十"]];
        for (const [size, symbol] of units) {
            const count = Math.floor(value / size);
            if (count > 0)
                result += (count > 1 ? digits[count] : "") + symbol;
            value %= size;
        }
        return result + (value > 0 ? digits[value] : "");
    }

    implicitWidth: content.width
    implicitHeight: 32

    Row {
        id: content

        height: parent.height
        spacing: 10

        WorkspaceStrip {
            outputName: root.outputName
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            text: root.activeWorkspace
                ? root.activeWorkspace.name || root.japaneseNumber(root.activeWorkspace.index)
                : "Desktop"
            color: Theme.primaryTextColor
            font.family: Typography.bodyFontFamily
            font.pixelSize: 14
            font.weight: Font.Medium
            verticalAlignment: Text.AlignVCenter
        }
    }
}
