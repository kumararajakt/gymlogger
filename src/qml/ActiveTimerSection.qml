import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int elapsedSeconds: 0
    property bool timerRunning: false
    property bool onBreak: false

    signal startPauseClicked()
    signal resetClicked()
    signal breakClicked()

    function formatTime(totalSeconds) {
        var hrs = Math.floor(totalSeconds / 3600);
        var mins = Math.floor((totalSeconds % 3600) / 60);
        var secs = totalSeconds % 60;
        if (hrs > 0)
            return (hrs < 10 ? "0" : "") + hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        color: onBreak ? Qt.rgba(0.1, 0.6, 0.3, 0.08) : Qt.rgba(0, 0, 0, 0.03)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: onBreak ? "BREAK" : "TIME"
                font.pixelSize: 11
                font.bold: true
                color: onBreak ? "#4caf50" : "#999"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.formatTime(root.elapsedSeconds)
                font.pixelSize: 48
                font.bold: true
                font.family: "Monospace"
                color: onBreak ? "#4caf50" : "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                spacing: 8
                Layout.alignment: Qt.AlignHCenter

                Controls.Button {
                    text: timerRunning ? "Pause" : "Start"
                    implicitWidth: 80
                    onClicked: root.startPauseClicked()
                }

                Controls.Button {
                    text: "Reset"
                    implicitWidth: 80
                    onClicked: root.resetClicked()
                }

                Controls.Button {
                    text: onBreak ? "Resume" : "Take Break"
                    implicitWidth: 90
                    onClicked: root.breakClicked()
                }
            }
        }
    }
}
