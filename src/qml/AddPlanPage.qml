import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "PlanWorkoutUtils.js" as PlanWorkoutUtils

Kirigami.Page {
    id: addPlanPage
    padding: 0

    title: "New Plan"

    property var planWorkouts: []
    property var reminderDays: []
    property string reminderTime: "08:00"
    property string planName: ""
    property bool reminderEnabled: false

    property var planModel: applicationWindow().planModel

    function setPlanWorkouts(items) {
        planWorkouts = PlanWorkoutUtils.normalizeWorkoutList(items);
    }

    function savePlan() {
        if (planName.length === 0 || planWorkouts.length === 0)
            return;
        var days = reminderEnabled ? reminderDays : []
        var time = reminderEnabled ? reminderTime : ""
        planModel.addPlan(planName, planWorkouts, days, time);
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
                spacing: 12

                RowLayout {
                    Controls.Label {
                        text: "Workouts"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#666"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Controls.Button {
                        text: "+ Add Workout"
                        onClicked: {
                            var page = applicationWindow().pageStack.push(Qt.resolvedUrl("WorkoutPage.qml"), {
                                selectMode: true,
                                planWorkouts: planWorkouts
                            });

                            page.selectionDone.connect(function (items) {
                                setPlanWorkouts(items);
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

                    WorkoutPlanCard {
                        Layout.fillWidth: true
                        workoutData: modelData
                        workoutIndex: index
                        onRemoveRequested: {
                            var arr = [];
                            for (var i = 0; i < planWorkouts.length; i++) {
                                if (i !== workoutIndex)
                                    arr.push(planWorkouts[i]);
                            }
                            planWorkouts = arr;
                        }
                        onFieldChanged: function(idx, fieldName, fieldValue) {
                            var arr = planWorkouts.slice();
                            var obj = {};
                            for (var key in arr[idx])
                                obj[key] = arr[idx][key];
                            obj[fieldName] = fieldValue;
                            arr[idx] = obj;
                            planWorkouts = arr;
                        }
                        onReorderRequested: function(fromIdx, toIdx) {
                            var arr = planWorkouts.slice();
                            var item = arr.splice(fromIdx, 1)[0];
                            arr.splice(toIdx, 0, item);
                            planWorkouts = arr;
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

                RowLayout {
                    Text {
                        text: "Reminder"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#666"
                    }
                    Item { Layout.fillWidth: true }
                    Controls.CheckBox {
                        id: reminderCheck
                        checked: reminderEnabled
                        onCheckedChanged: {
                            reminderEnabled = checked
                            if (!checked) {
                                reminderDays = []
                                reminderTime = "08:00"
                            }
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    enabled: reminderEnabled
                    opacity: enabled ? 1.0 : 0.4

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
                    enabled: reminderEnabled
                    opacity: enabled ? 1.0 : 0.4

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
                enabled: planName.length > 0 && planWorkouts.length > 0
                onClicked: savePlan()
            }
        }
    }
}
