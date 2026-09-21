import QtQuick
import QtQuick.Controls
import "../../components/theme"

Rectangle {
    id: root

    property date today: new Date()
    property date displayedMonth: new Date(today.getFullYear(), today.getMonth(), 1)
    readonly property int firstWeekday: (displayedMonth.getDay() + 6) % 7

    function resetMonth(): void {
        displayedMonth = new Date(today.getFullYear(), today.getMonth(), 1);
    }

    function shiftMonth(offset: int): void {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + offset, 1);
    }

    function dateAt(index: int): date {
        return new Date(displayedMonth.getFullYear(), displayedMonth.getMonth(), 1 - firstWeekday + index);
    }

    implicitWidth: 348
    implicitHeight: 370
    radius: 9
    color: Theme.menuBarBackgroundColor
    border.color: Theme.spotlightBorderColor
    Keys.onLeftPressed: shiftMonth(-1)
    Keys.onRightPressed: shiftMonth(1)
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) {
            resetMonth();
            event.accepted = true;
        }
    }

    // Absorb clicks inside the calendar instead of dismissing the popup.
    MouseArea { anchors.fill: parent }

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
        height: 32

        Row {
            id: navigation
            spacing: 2
            CalendarButton { text: "‹"; Accessible.name: "Previous month"; onClicked: root.shiftMonth(-1) }
            CalendarButton { text: "›"; Accessible.name: "Next month"; onClicked: root.shiftMonth(1) }
        }

        Text {
            anchors { left: navigation.right; right: todayButton.left; verticalCenter: parent.verticalCenter }
            text: Qt.formatDate(root.displayedMonth, "MMMM yyyy")
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }

        CalendarButton {
            id: todayButton
            anchors.right: parent.right
            text: "⊙"
            Accessible.name: "Go to today"
            onClicked: root.resetMonth()
        }
    }

    Grid {
        id: days
        anchors { top: header.bottom; left: parent.left; right: parent.right; topMargin: 12; leftMargin: 16; rightMargin: 16 }
        columns: 7

        Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]
            Text {
                required property string modelData
                width: days.width / 7
                height: 28
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.secondaryTextColor
                font.family: Typography.menuBarFontFamily
                font.pixelSize: 11
                font.bold: true
            }
        }

        Repeater {
            model: 42
            Item {
                id: day
                required property int index
                readonly property date value: root.dateAt(index)
                readonly property bool currentMonth: value.getMonth() === root.displayedMonth.getMonth()
                readonly property bool isToday: value.toDateString() === root.today.toDateString()
                width: days.width / 7
                height: 44

                Rectangle {
                    anchors.centerIn: parent
                    width: 36
                    height: 36
                    radius: 18
                    visible: day.isToday
                    color: Theme.spotlightSelectionColor
                }

                Text {
                    anchors.centerIn: parent
                    text: day.value.getDate()
                    color: day.currentMonth || day.isToday ? Theme.menuBarTextColor : Theme.menuBarMutedColor
                    font.family: Typography.menuBarFontFamily
                    font.pixelSize: 16
                    font.weight: day.isToday ? Font.DemiBold : Font.Normal
                }
            }
        }
    }

    component CalendarButton: Button {
        id: button
        width: 28
        height: 32
        hoverEnabled: true
        ToolTip.visible: hovered
        ToolTip.text: Accessible.name
        contentItem: Text {
            text: button.text
            color: Theme.menuBarTextColor
            font.family: Typography.menuBarFontFamily
            font.pixelSize: 23
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 5
            color: button.hovered || button.activeFocus ? Theme.menuBarHoverColor : "transparent"
        }
    }
}
