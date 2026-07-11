import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: addPlanPage
    padding: 0

    title: "New Plan"

    property var planWorkouts: []
    property var reminderDays: []
    property string reminderTime: "08:00"
    property string planName: ""

    property var planModel: applicationWindow().planModel

    function savePlan() {
        if (planName.length === 0)
            return;
        planModel.addPlan(planName, planWorkouts, reminderDays, reminderTime);
        applicationWindow().pageStack.pop();
    }

    function toggleDay(day) {
        var arr = [];
        for (var i = 0; i < reminderDays.length; i++) {
            if (reminderDays[i] !== day)
                arr.push(reminderDays[i]);
        }
        if (arr.length === reminderDays.length)
            arr.push(day);
        reminderDays = arr;
    }

    Flickable {
        anchors.fill: parent
        contentHeight: formContent.height
        clip: true
        Controls.ScrollBar.vertical: Controls.ScrollBar {}

        ColumnLayout {
            id: formContent
            width: parent.width
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                color: "transparent"
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Text {
                    text: "Plan Name"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#666"
                }

                Controls.TextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "e.g. Upper Body Strength"
                    onTextChanged: planName = text
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 8

                RowLayout {
                    Text {
                        text: "Workouts"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#666"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Controls.Button {
                        text: "+ Add"
                        onClicked: {
                            var page = applicationWindow().pageStack.push(Qt.resolvedUrl("WorkoutPage.qml"), {
                                selectMode: true,
                                planWorkouts: planWorkouts
                            });

                            page.selectionDone.connect(function (items) {
                                planWorkouts = items;
                            });
                        }
                    }
                }

                Text {
                    text: planWorkouts.length === 0 ? "No workouts added yet" : planWorkouts.length + " workout" + (planWorkouts.length !== 1 ? "s" : "") + " selected"
                    font.pixelSize: 12
                    color: planWorkouts.length === 0 ? "#bbb" : "#888"
                    Layout.bottomMargin: 4
                }

                Repeater {
                    model: planWorkouts
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 6
                            color: Qt.rgba(0, 0, 0, 0.04)

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

                        Controls.ToolButton {
                            icon.name: "list-remove"
                            implicitWidth: 28
                            implicitHeight: 28
                            onClicked: {
                                var arr = [];
                                for (var i = 0; i < planWorkouts.length; i++) {
                                    if (i !== index)
                                        arr.push(planWorkouts[i]);
                                }
                                planWorkouts = arr;
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 10

                Text {
                    text: "Reminder"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#666"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                        Controls.Button {
                            text: modelData
                            checkable: true
                            checked: reminderDays.indexOf(modelData) >= 0
                            onClicked: toggleDay(modelData)
                        }
                    }
                }

                RowLayout {
                    spacing: 8
                    Layout.topMargin: 4

                    Text {
                        text: "Time"
                        font.pixelSize: 13
                        color: "#666"
                    }

                    Controls.SpinBox {
                        id: hourSpin
                        from: 0
                        to: 23
                        value: parseInt(reminderTime.split(":")[0]) || 8
                        onValueChanged: {
                            var min = minuteSpin.value;
                            reminderTime = (value < 10 ? "0" : "") + value + ":" + (min < 10 ? "0" : "") + min;
                        }
                    }

                    Text {
                        text: ":"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Controls.SpinBox {
                        id: minuteSpin
                        from: 0
                        to: 59
                        stepSize: 5
                        value: parseInt(reminderTime.split(":")[1]) || 0
                        onValueChanged: {
                            var hr = hourSpin.value;
                            reminderTime = (hr < 10 ? "0" : "") + hr + ":" + (value < 10 ? "0" : "") + value;
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            Controls.Button {
                text: "Save Plan"
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                Layout.bottomMargin: 24
                enabled: planName.length > 0
                onClicked: savePlan()
            }
        }
    }
}
