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
                    color: Kirigami.Theme.disabledTextColor
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
                color: Kirigami.Theme.separatorColor
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
                        color: Kirigami.Theme.disabledTextColor
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
                    color: planWorkouts.length === 0 ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
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
                color: Kirigami.Theme.separatorColor
            }

            ReminderSection {
                reminderEnabled: addPlanPage.reminderEnabled
                reminderDays: addPlanPage.reminderDays
                reminderTime: addPlanPage.reminderTime
                onReminderToggled: function(enabled) {
                    addPlanPage.reminderEnabled = enabled
                    if (!enabled) {
                        addPlanPage.reminderDays = []
                        addPlanPage.reminderTime = "08:00"
                    }
                }
                onDayToggled: function(day) {
                    addPlanPage.toggleDay(day)
                }
                onReminderTimeChanged: addPlanPage.reminderTime = reminderTime
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Kirigami.Theme.separatorColor
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
