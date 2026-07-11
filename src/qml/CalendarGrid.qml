import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property date selectedDate: new Date()
    property var sessionDates: []
    property int viewMonth: new Date().getMonth()
    property int viewYear: new Date().getFullYear()

    signal dateClicked(string dateStr)

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfWeek(year, month) {
        return new Date(year, month, 1).getDay();
    }

    function formatSelectedDate() {
        var months = ["January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"];
        return months[viewMonth] + " " + viewYear;
    }

    function hasSession(day) {
        var dateStr = viewYear + "-" +
                      (viewMonth + 1 < 10 ? "0" : "") + (viewMonth + 1) + "-" +
                      (day < 10 ? "0" : "") + day;
        for (var i = 0; i < sessionDates.length; i++) {
            if (sessionDates[i] === dateStr) return true;
        }
        return false;
    }

    function isToday(day) {
        var now = new Date();
        return day === now.getDate() && viewMonth === now.getMonth() && viewYear === now.getFullYear();
    }

    function isSelected(day) {
        return day === selectedDate.getDate() && viewMonth === selectedDate.getMonth() && viewYear === selectedDate.getFullYear();
    }

    function formatDayStr(day) {
        return viewYear + "-" +
               (viewMonth + 1 < 10 ? "0" : "") + (viewMonth + 1) + "-" +
               (day < 10 ? "0" : "") + day;
    }

    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        Layout.rightMargin: 8

        Controls.ToolButton {
            text: "◀"
            onClicked: {
                if (viewMonth === 0) {
                    viewMonth = 11;
                    viewYear--;
                } else {
                    viewMonth--;
                }
            }
        }

        Item { Layout.fillWidth: true }

        Controls.Label {
            text: formatSelectedDate()
            font.pixelSize: 15
            font.bold: true
            color: Kirigami.Theme.textColor
        }

        Item { Layout.fillWidth: true }

        Controls.ToolButton {
            text: "▶"
            onClicked: {
                if (viewMonth === 11) {
                    viewMonth = 0;
                    viewYear++;
                } else {
                    viewMonth++;
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4

        Repeater {
            model: ["S", "M", "T", "W", "T", "F", "S"]

            Controls.Label {
                Layout.fillWidth: true
                text: modelData
                font.pixelSize: 11
                font.bold: true
                color: Kirigami.Theme.disabledTextColor
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        columnSpacing: 2
        rowSpacing: 2
        Layout.leftMargin: 4
        Layout.rightMargin: 4

        Repeater {
            model: getFirstDayOfWeek(viewYear, viewMonth)

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
            }
        }

        Repeater {
            model: getDaysInMonth(viewYear, viewMonth)

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 36

                Rectangle {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    radius: isSelected(modelData + 1) ? 16 : (isToday(modelData + 1) ? 16 : 4)
                    color: isSelected(modelData + 1) ? Kirigami.Theme.highlightColor :
                           isToday(modelData + 1) ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Controls.Label {
                            text: modelData + 1
                            font.pixelSize: 13
                            font.bold: isSelected(modelData + 1) || isToday(modelData + 1)
                            color: isSelected(modelData + 1) ? "white" : Kirigami.Theme.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Rectangle {
                            visible: hasSession(modelData + 1)
                            width: 5
                            height: 5
                            radius: 2.5
                            color: isSelected(modelData + 1) ? "white" : Kirigami.Theme.positiveColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            selectedDate = new Date(viewYear, viewMonth, modelData + 1);
                            root.dateClicked(formatDayStr(modelData + 1));
                        }
                    }
                }
            }
        }
    }
}
