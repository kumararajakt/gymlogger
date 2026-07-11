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
    property string selectedDateStr: ""
    property var filteredSessions: []
    property bool showingFiltered: false

    function formatDuration(totalSeconds) {
        var hrs = Math.floor(totalSeconds / 3600);
        var mins = Math.floor((totalSeconds % 3600) / 60);
        var secs = totalSeconds % 60;
        if (hrs > 0)
            return (hrs < 10 ? "0" : "") + hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    function onDateClicked(dateStr) {
        if (selectedDateStr === dateStr) {
            selectedDateStr = "";
            showingFiltered = false;
            filteredSessions = [];
        } else {
            selectedDateStr = dateStr;
            filteredSessions = sessionModel.getSessionsForDate(dateStr);
            showingFiltered = true;
        }
    }

    function clearFilter() {
        selectedDateStr = "";
        showingFiltered = false;
        filteredSessions = [];
    }

    function refreshFiltered() {
        if (showingFiltered && selectedDateStr.length > 0)
            filteredSessions = sessionModel.getSessionsForDate(selectedDateStr);
    }

    Connections {
        target: sessionModel
        function onCountChanged() {
            refreshFiltered();
            calendarGrid.sessionDates = sessionModel.getDatesWithSessions();
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainLayout.height
        clip: true
        Controls.ScrollBar.vertical: Controls.ScrollBar {}

        ColumnLayout {
            id: mainLayout
            width: parent.width
            spacing: 0

            CalendarGrid {
                id: calendarGrid
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 8
                sessionDates: sessionModel.getDatesWithSessions()
                onDateClicked: function(dateStr) {
                    logPage.onDateClicked(dateStr);
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 8
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Kirigami.Theme.separatorColor
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                spacing: 8
                visible: showingFiltered

                Controls.Label {
                    text: "Sessions on " + selectedDateStr
                    font.pixelSize: 13
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    Layout.fillWidth: true
                }

                Controls.Button {
                    text: "Show All"
                    flat: true
                    onClicked: clearFilter()
                }
            }

            Repeater {
                model: showingFiltered ? filteredSessions : []

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            Layout.fillWidth: true

                            Controls.Label {
                                text: modelData.sessionPlanName
                                font.bold: true
                                font.pixelSize: 15
                                elide: Text.ElideRight
                            }

                            Controls.Label {
                                text: modelData.sessionDateTime + "  •  " + formatDuration(modelData.sessionDuration)
                                font.pixelSize: 12
                                color: Kirigami.Theme.disabledTextColor
                                elide: Text.ElideRight
                            }
                        }

                        Controls.ToolButton {
                            text: '...'
                            onClicked: {
                                sessionModel.removeSession(modelData.sessionId);
                            }
                        }
                    }

                    Repeater {
                        model: modelData.sessionWorkouts

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 6
                                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: modelData.gifUrl || ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            Controls.Label {
                                text: modelData.name ? modelData.name.charAt(0).toUpperCase() + modelData.name.slice(1) : ""
                                font.pixelSize: 13
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Controls.Label {
                                text: {
                                    var sets = modelData.sets || [];
                                    var done = 0;
                                    for (var i = 0; i < sets.length; i++)
                                        if (sets[i].done) done++;
                                    return done + "/" + sets.length + " sets";
                                }
                                font.pixelSize: 11
                                    color: Kirigami.Theme.disabledTextColor
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            Layout.topMargin: 4
                            color: Kirigami.Theme.separatorColor
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: showingFiltered ? null : sessionModel
                clip: true
                visible: !showingFiltered

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
                                    color: Kirigami.Theme.disabledTextColor
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
                                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: modelData.gifUrl || ""
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                    }
                                }

                                Controls.Label {
                                    text: modelData.name ? modelData.name.charAt(0).toUpperCase() + modelData.name.slice(1) : ""
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Controls.Label {
                                    text: {
                                        var sets = modelData.sets || [];
                                        var done = 0;
                                        for (var i = 0; i < sets.length; i++)
                                            if (sets[i].done) done++;
                                        return done + "/" + sets.length + " sets";
                                    }
                                    font.pixelSize: 11
                                    color: Kirigami.Theme.disabledTextColor
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: (showingFiltered && filteredSessions.length === 0) || (!showingFiltered && sessionModel.count === 0)
                spacing: 16

                Item { Layout.preferredHeight: 40 }

                Kirigami.Icon {
                    source: "view-history"
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignHCenter
                    color: Kirigami.Theme.disabledTextColor
                }

                Controls.Label {
                    text: showingFiltered ? "No sessions on this date" : "No sessions logged"
                    font.pixelSize: 18
                    font.bold: true
                    color: Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }

                Controls.Label {
                    text: showingFiltered ? "Try another date" : "Start a plan to log your first session"
                    font.pixelSize: 13
                    color: Kirigami.Theme.disabledTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
