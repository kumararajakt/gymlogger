import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.tutorial

Kirigami.Page {
    id: logPage
    padding: 0

    title: "Logs"

    property var sessionModel: applicationWindow().sessionModel

    function formatDuration(totalSeconds) {
        var hrs = Math.floor(totalSeconds / 3600);
        var mins = Math.floor((totalSeconds % 3600) / 60);
        var secs = totalSeconds % 60;
        if (hrs > 0)
            return (hrs < 10 ? "0" : "") + hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    ListView {
        anchors.fill: parent
        model: sessionModel
        clip: true

        delegate: Controls.ItemDelegate {
            width: parent.width

            contentItem: ColumnLayout {
                width: parent.width
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true

                        Controls.Label {
                            text: model.sessionPlanName
                            font.bold: true
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }

                        Controls.Label {
                            text: model.sessionDateTime + "  •  " + formatDuration(model.sessionDuration)
                            font.pixelSize: 12
                            color: "#888"
                            elide: Text.ElideRight
                        }
                    }

                    Controls.ToolButton {
                        text: '...'
                        onClicked: sessionModel.removeSession(model.sessionId)
                    }
                }

                Repeater {
                    model: model.sessionWorkouts

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 6
                            color: Qt.rgba(0, 0, 0, 0.04)
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: modelData.gifUrl || ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }
                        }

                        Text {
                            text: modelData.name ? modelData.name.charAt(0).toUpperCase() + modelData.name.slice(1) : ""
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            text: {
                                var sets = modelData.sets || [];
                                var done = 0;
                                for (var i = 0; i < sets.length; i++)
                                    if (sets[i].done) done++;
                                return done + "/" + sets.length + " sets";
                            }
                            font.pixelSize: 11
                            color: "#888"
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        visible: sessionModel.count === 0

        Kirigami.Icon {
            source: "view-history"
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignHCenter
            color: "#ccc"
        }

        Controls.Label {
            text: "No sessions logged"
            font.pixelSize: 18
            font.bold: true
            color: "#999"
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.Label {
            text: "Start a plan to log your first session"
            font.pixelSize: 13
            color: "#bbb"
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
