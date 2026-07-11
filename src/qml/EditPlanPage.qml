import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "PlanWorkoutUtils.js" as PlanWorkoutUtils

Kirigami.Page {
    id: editPlanPage
    padding: 0

    property int planId: 0
    property var planModel: applicationWindow().planModel

    title: "Edit Plan"

    property var planWorkouts: []
    property var reminderDays: []
    property string reminderTime: "08:00"
    property string planName: ""
    property bool reminderEnabled: false

    function setPlanWorkouts(items) {
        planWorkouts = PlanWorkoutUtils.normalizeWorkoutList(items);
    }

    Component.onCompleted: {
        var plan = planModel.getPlan(planId)
        if (plan.planName) {
            planName = plan.planName
            setPlanWorkouts(plan.planWorkouts ? plan.planWorkouts.slice() : [])
            var days = plan.reminderDays
            reminderDays = days ? days.slice() : []
            reminderTime = plan.reminderTime || ""
            reminderEnabled = days.length > 0
            nameField.text = planName
        }
    }

    function savePlan() {
        if (planName.length === 0 || planWorkouts.length === 0) return
        var days = reminderEnabled ? reminderDays : []
        var time = reminderEnabled ? reminderTime : ""
        planModel.updatePlan(planId, planName, planWorkouts, days, time)
        applicationWindow().pageStack.pop()
    }

    function toggleDay(day) {
        var arr = []
        for (var i = 0; i < reminderDays.length; i++) {
            if (reminderDays[i] !== day) arr.push(reminderDays[i])
        }
        if (arr.length === reminderDays.length) arr.push(day)
        reminderDays = arr
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
                    Item { Layout.fillWidth: true }
                    Controls.Button {
                        text: "+ Add Workout"
                        onClicked: {
                            var page = applicationWindow().pageStack.push(Qt.resolvedUrl("WorkoutPage.qml"), {
                            selectMode: true,
                            planWorkouts: planWorkouts
                            })

                            page.selectionDone.connect(function (items) {
                                setPlanWorkouts(items)
                            })
                        }
                    }
                }

                Controls.Label {
                    text: "No workouts added yet"
                    font.pixelSize: 12
                    visible: planWorkouts.length === 0
                    Layout.bottomMargin: 4
                }

                Repeater {
                    model: planWorkouts

                    WorkoutPlanCard {
                        Layout.fillWidth: true
                        workoutData: modelData
                        workoutIndex: index
                        onRemoveRequested: {
                            var arr = []
                            for (var i = 0; i < planWorkouts.length; i++) {
                                if (i !== workoutIndex) arr.push(planWorkouts[i])
                            }
                            planWorkouts = arr
                        }
                        onFieldChanged: function(idx, fieldName, fieldValue) {
                            var arr = planWorkouts.slice()
                            var obj = {}
                            for (var key in arr[idx])
                                obj[key] = arr[idx][key]
                            obj[fieldName] = fieldValue
                            arr[idx] = obj
                            planWorkouts = arr
                        }
                        onReorderRequested: function(fromIdx, toIdx) {
                            var arr = planWorkouts.slice()
                            var item = arr.splice(fromIdx, 1)[0]
                            arr.splice(toIdx, 0, item)
                            planWorkouts = arr
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
                reminderEnabled: editPlanPage.reminderEnabled
                reminderDays: editPlanPage.reminderDays
                reminderTime: editPlanPage.reminderTime
                onReminderToggled: function(enabled) {
                    editPlanPage.reminderEnabled = enabled
                    if (!enabled) {
                        editPlanPage.reminderDays = []
                        editPlanPage.reminderTime = "08:00"
                    }
                }
                onDayToggled: function(day) {
                    editPlanPage.toggleDay(day)
                }
                onReminderTimeChanged: editPlanPage.reminderTime = reminderTime
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
                text: "Save Changes"
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
