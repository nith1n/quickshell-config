// CalendarMenu.qml
import QtQuick
import Quickshell
import "../helpers"

PopupWindow {
    id: root

    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    implicitWidth: 300
    implicitHeight: menuColumn.implicitHeight + 28
    visible: false
    color: "transparent"
    grabFocus: true

    // State for displayed month/year
    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth() // 0-11

    // Reset to current date when opened
    onVisibleChanged: {
        if (visible) {
            var now = new Date();
            root.currentYear = now.getFullYear();
            root.currentMonth = now.getMonth();
        }
    }

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    readonly property var dayNames: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    readonly property var calendarCells: generateCalendar(currentYear, currentMonth)

    function prevMonth() {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
    }

    function resetToToday() {
        var now = new Date();
        root.currentYear = now.getFullYear();
        root.currentMonth = now.getMonth();
    }

    function generateCalendar(year, month) {
        var cells = [];
        var firstDayIndex = new Date(year, month, 1).getDay(); // 0 = Sun
        var daysInPrevMonth = new Date(year, month, 0).getDate();
        var daysInCurrentMonth = new Date(year, month + 1, 0).getDate();

        var now = new Date();
        var isThisYear = now.getFullYear() === year;
        var isThisMonth = now.getMonth() === month;
        var todayDate = now.getDate();

        // Previous month filler days
        for (var i = 0; i < firstDayIndex; i++) {
            cells.push({
                day: daysInPrevMonth - firstDayIndex + 1 + i,
                isCurrentMonth: false,
                isToday: false
            });
        }

        // Current month days
        for (var d = 1; d <= daysInCurrentMonth; d++) {
            cells.push({
                day: d,
                isCurrentMonth: true,
                isToday: isThisYear && isThisMonth && (d === todayDate)
            });
        }

        // Next month filler days (fill up to 35 or 42 cells)
        var targetLength = cells.length > 35 ? 42 : 35;
        var nextDay = 1;
        while (cells.length < targetLength) {
            cells.push({
                day: nextDay,
                isCurrentMonth: false,
                isToday: false
            });
            nextDay++;
        }

        return cells;
    }

    Rectangle {
        id: menuBackground
        anchors.fill: parent
        anchors.topMargin: 8
        radius: 14
        color: Theme.pillBg
        border.width: 1
        border.color: Qt.alpha(Theme.text, 0.08)

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 14
            spacing: 12

            // -----------------------------------------------------------------
            // Digital Clock & Full Date Header
            // -----------------------------------------------------------------
            Row {
                width: parent.width
                spacing: 8

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 36
                    spacing: 2

                    Text {
                        text: Time.formattedTime
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 1.5
                        font.bold: true
                    }

                    Text {
                        text: Time.formattedDate
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize * 0.95
                        font.bold: true
                    }
                }

                // Reset to today button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: todayMouse.containsMouse ? Theme.pillBgHover : Qt.alpha(Theme.text, 0.05)

                    Text {
                        anchors.centerIn: parent
                        text: "󰸗"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: Theme.accent
                    }

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.resetToToday()
                    }
                }
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.alpha(Theme.text, 0.08)
            }

            // -----------------------------------------------------------------
            // Month Navigation (Prev, Month Year, Next)
            // -----------------------------------------------------------------
            Item {
                width: parent.width
                height: 28

                // Previous Month Button
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: prevMouse.containsMouse ? Theme.pillBgHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅁"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: prevMouse.containsMouse ? Theme.text : Theme.textMuted
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prevMonth()
                    }
                }

                // Month Year Label
                Text {
                    anchors.centerIn: parent
                    text: root.monthNames[root.currentMonth] + " " + root.currentYear
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize * 1.05
                    font.bold: true
                }

                // Next Month Button
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: nextMouse.containsMouse ? Theme.pillBgHover : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅂"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: nextMouse.containsMouse ? Theme.text : Theme.textMuted
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }

            // -----------------------------------------------------------------
            // Day of Week Header (Su, Mo, Tu, We, Th, Fr, Sa)
            // -----------------------------------------------------------------
            Grid {
                width: parent.width
                columns: 7
                spacing: 0

                Repeater {
                    model: root.dayNames

                    Item {
                        width: parent.width / 7
                        height: 20

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: (index === 0 || index === 6) ? Qt.alpha(Theme.accent, 0.7) : Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 0.85
                            font.bold: true
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // Calendar Days Grid
            // -----------------------------------------------------------------
            Grid {
                id: daysGrid
                width: parent.width
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                Repeater {
                    model: root.calendarCells

                    Rectangle {
                        required property var modelData
                        property var cell: modelData

                        width: daysGrid.width / 7
                        height: 30
                        radius: 8

                        color: cell.isToday
                            ? Theme.accent
                            : (cellMouse.containsMouse && cell.isCurrentMonth
                                ? Qt.alpha(Theme.text, 0.08)
                                : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: cell.day.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize * 0.95
                            font.bold: cell.isToday || cell.isCurrentMonth

                            color: cell.isToday
                                ? Theme.barBg
                                : (cell.isCurrentMonth
                                    ? Theme.text
                                    : Qt.alpha(Theme.textMuted, 0.35))
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: cell.isCurrentMonth
                        }
                    }
                }
            }
        }
    }
}
