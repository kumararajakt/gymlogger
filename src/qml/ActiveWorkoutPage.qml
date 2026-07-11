import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.tutorial

Kirigami.Page {
    id: activeWorkoutPage
    padding: 0
    title: planName

    property string planName: ""
    property var planWorkouts: []
    property int currentWorkoutIndex: 0
    property var currentWorkout: planWorkouts.length > 0 ? planWorkouts[currentWorkoutIndex] : ({})

    property var setStates: []
    property var workoutSetStates: []

    property int elapsedSeconds: 0
    property bool timerRunning: false
    property bool onBreak: false

    property var sessionModel: applicationWindow().sessionModel

    Timer {
        id: workoutTimer
        interval: 1000
        repeat: true
        running: timerRunning
        onTriggered: elapsedSeconds++
    }

    function initSets() {
        var sets = currentWorkout.sets || 4;
        var reps = currentWorkout.reps || 8;
        var arr = [];
        for (var i = 0; i < sets; i++)
            arr.push({ done: false, reps: reps });
        setStates = arr;
    }

    function saveCurrentWorkoutState() {
        var arr = workoutSetStates.slice();
        arr[currentWorkoutIndex] = setStates.slice();
        workoutSetStates = arr;
    }

    function allSetsDone() {
        for (var i = 0; i < setStates.length; i++)
            if (!setStates[i].done) return false;
        return setStates.length > 0;
    }

    function goNext() {
        if (currentWorkoutIndex < planWorkouts.length - 1) {
            saveCurrentWorkoutState();
            currentWorkoutIndex++;
            currentWorkout = planWorkouts[currentWorkoutIndex];
            if (workoutSetStates.length > currentWorkoutIndex && workoutSetStates[currentWorkoutIndex])
                setStates = workoutSetStates[currentWorkoutIndex].slice();
            else
                initSets();
        }
    }

    function goPrev() {
        if (currentWorkoutIndex > 0) {
            saveCurrentWorkoutState();
            currentWorkoutIndex--;
            currentWorkout = planWorkouts[currentWorkoutIndex];
            if (workoutSetStates.length > currentWorkoutIndex && workoutSetStates[currentWorkoutIndex])
                setStates = workoutSetStates[currentWorkoutIndex].slice();
            else
                initSets();
        }
    }

    function finishSession() {
        saveCurrentWorkoutState();
        timerRunning = false;

        var sessionWorkouts = [];
        for (var w = 0; w < planWorkouts.length; w++) {
            var workout = planWorkouts[w];
            var states = workoutSetStates.length > w ? workoutSetStates[w] : [];
            var sets = [];
            for (var s = 0; s < states.length; s++) {
                sets.push({
                    setNumber: s + 1,
                    done: states[s].done,
                    reps: states[s].reps
                });
            }
            sessionWorkouts.push({
                exerciseId: workout.exerciseId || "",
                name: workout.name || "",
                gifUrl: workout.gifUrl || "",
                bodyParts: workout.bodyParts || "",
                equipments: workout.equipments || "",
                targetMuscles: workout.targetMuscles || "",
                sets: sets
            });
        }

        sessionModel.addSession(planName, sessionWorkouts, elapsedSeconds);
        applicationWindow().pageStack.pop();
    }

    function completeAndAdvance() {
        var arr = [];
        for (var i = 0; i < setStates.length; i++)
            arr.push({ done: true, reps: setStates[i].reps });
        setStates = arr;
        if (currentWorkoutIndex === planWorkouts.length - 1) {
            finishSession();
        } else {
            goNext();
        }
    }

    Component.onCompleted: {
        initSets();
        timerRunning = true;
    }

    onCurrentWorkoutIndexChanged: initSets()

    Flickable {
        anchors.fill: parent
        contentHeight: mainLayout.height
        clip: true
        Controls.ScrollBar.vertical: Controls.ScrollBar {}

        ColumnLayout {
            id: mainLayout
            width: parent.width
            spacing: 0

            ActiveTimerSection {
                Layout.fillWidth: true
                elapsedSeconds: activeWorkoutPage.elapsedSeconds
                timerRunning: activeWorkoutPage.timerRunning
                onBreak: activeWorkoutPage.onBreak
                onStartPauseClicked: {
                    if (!timerRunning) onBreak = false;
                    timerRunning = !timerRunning;
                }
                onResetClicked: {
                    timerRunning = false;
                    elapsedSeconds = 0;
                    onBreak = false;
                }
                onBreakClicked: {
                    if (onBreak) {
                        onBreak = false;
                        timerRunning = true;
                    } else {
                        onBreak = true;
                        timerRunning = false;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 12
                Layout.bottomMargin: 4
                spacing: 8

                Text {
                    text: "Workout " + (currentWorkoutIndex + 1) + " of " + planWorkouts.length
                    font.pixelSize: 12
                    color: "#888"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: allSetsDone() ? "All sets complete!" : ""
                    font.pixelSize: 12
                    font.bold: true
                    color: "#4caf50"
                }
            }

            Controls.ProgressBar {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.preferredHeight: 6
                from: 0
                to: planWorkouts.length > 0 ? planWorkouts.length : 1
                value: currentWorkoutIndex + 1
            }

            ExerciseInfoCard {
                exercise: currentWorkout
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 12
                spacing: 8

                Text {
                    text: "SETS"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#666"
                }

                Repeater {
                    model: setStates

                    SetRow {
                        Layout.fillWidth: true
                        done: modelData.done
                        setNumber: index + 1
                        reps: modelData.reps
                        onToggled: function(checked) {
                            var arr = setStates.slice();
                            arr[index] = { done: checked, reps: arr[index].reps };
                            setStates = arr;
                        }
                        onRepsModified: function(newReps) {
                            var arr = setStates.slice();
                            arr[index] = { done: arr[index].done, reps: newReps };
                            setStates = arr;
                        }
                    }
                }

                Controls.Button {
                    text: "+ Add Set"
                    Layout.fillWidth: true
                    onClicked: {
                        var arr = setStates.slice();
                        var lastReps = arr.length > 0 ? arr[arr.length - 1].reps : (currentWorkout.reps || 8);
                        arr.push({ done: false, reps: lastReps });
                        setStates = arr;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 12
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 12
                spacing: 10

                Controls.Button {
                    text: "Complete"
                    Layout.fillWidth: true
                    onClicked: completeAndAdvance()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 24
                spacing: 10

                Controls.Button {
                    text: "Previous"
                    Layout.fillWidth: true
                    enabled: currentWorkoutIndex > 0
                    onClicked: goPrev()
                }

                Controls.Button {
                    text: currentWorkoutIndex === planWorkouts.length - 1 ? "Finish" : "Next"
                    Layout.fillWidth: true
                    highlighted: true
                    onClicked: {
                        if (currentWorkoutIndex === planWorkouts.length - 1) {
                            finishSession();
                        } else {
                            goNext();
                        }
                    }
                }
            }
        }
    }
}
