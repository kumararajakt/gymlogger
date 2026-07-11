import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: activeWorkoutPage
    padding: 0
    title: planName

    property string planName: ""
    property var planWorkouts: []
    property int currentWorkoutIndex: 0
    property var currentWorkout: planWorkouts.length > 0 ? planWorkouts[currentWorkoutIndex] : ({})

    property var setStates: []

    property int elapsedSeconds: 0
    property bool timerRunning: false
    property bool onBreak: false

    Timer {
        id: workoutTimer
        interval: 1000
        repeat: true
        running: timerRunning
        onTriggered: {
            elapsedSeconds++;
        }
    }

    function formatTime(totalSeconds) {
        var hrs = Math.floor(totalSeconds / 3600);
        var mins = Math.floor((totalSeconds % 3600) / 60);
        var secs = totalSeconds % 60;
        if (hrs > 0)
            return (hrs < 10 ? "0" : "") + hrs + ":" + (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    function initSets() {
        var sets = currentWorkout.sets || 4;
        var reps = currentWorkout.reps || 8;
        var arr = [];
        for (var i = 0; i < sets; i++) {
            arr.push({ done: false, reps: reps });
        }
        setStates = arr;
    }

    function allSetsDone() {
        for (var i = 0; i < setStates.length; i++) {
            if (!setStates[i].done) return false;
        }
        return setStates.length > 0;
    }

    function goNext() {
        if (currentWorkoutIndex < planWorkouts.length - 1) {
            currentWorkoutIndex++;
            currentWorkout = planWorkouts[currentWorkoutIndex];
            initSets();
        }
    }

    function goPrev() {
        if (currentWorkoutIndex > 0) {
            currentWorkoutIndex--;
            currentWorkout = planWorkouts[currentWorkoutIndex];
            initSets();
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

            // Timer Section
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
                        text: formatTime(elapsedSeconds)
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
                            onClicked: {
                                if (!timerRunning) {
                                    onBreak = false;
                                }
                                timerRunning = !timerRunning;
                            }
                        }

                        Controls.Button {
                            text: "Reset"
                            implicitWidth: 80
                            onClicked: {
                                timerRunning = false;
                                elapsedSeconds = 0;
                                onBreak = false;
                            }
                        }

                        Controls.Button {
                            text: onBreak ? "Resume" : "Take Break"
                            implicitWidth: 90
                            onClicked: {
                                if (onBreak) {
                                    onBreak = false;
                                    timerRunning = true;
                                } else {
                                    onBreak = true;
                                    timerRunning = false;
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            // Progress bar
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

            // Exercise Info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                Layout.topMargin: 8
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140
                        radius: 12
                        color: Qt.rgba(0, 0, 0, 0.04)
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: currentWorkout.gifUrl || ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true

                            Controls.BusyIndicator {
                                anchors.centerIn: parent
                                running: parent.status === Image.Loading
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: currentWorkout.name ? currentWorkout.name.charAt(0).toUpperCase() + currentWorkout.name.slice(1) : ""
                            font.pixelSize: 18
                            font.bold: true
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6
                            visible: currentWorkout.equipments && currentWorkout.equipments.length > 0

                            Rectangle {
                                radius: 4
                                color: Qt.rgba(0.0, 0.7, 0.3, 0.12)
                                Layout.preferredWidth: equipTag.implicitWidth + 12
                                Layout.preferredHeight: 20

                                Text {
                                    id: equipTag
                                    anchors.centerIn: parent
                                    text: currentWorkout.equipments ? currentWorkout.equipments.charAt(0).toUpperCase() + currentWorkout.equipments.slice(1) : ""
                                    font.pixelSize: 10
                                    color: "#0d7d3b"
                                }
                            }
                        }

                        Text {
                            text: currentWorkout.bodyParts ? currentWorkout.bodyParts.charAt(0).toUpperCase() + currentWorkout.bodyParts.slice(1) : ""
                            font.pixelSize: 12
                            color: "#888"
                        }

                        Text {
                            text: currentWorkout.targetMuscles ? currentWorkout.targetMuscles.charAt(0).toUpperCase() + currentWorkout.targetMuscles.slice(1) : ""
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                color: Qt.rgba(0, 0, 0, 0.08)
            }

            // Sets Section
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

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Controls.CheckBox {
                            checked: modelData.done
                            onCheckedChanged: {
                                var arr = setStates.slice();
                                arr[index] = { done: checked, reps: arr[index].reps };
                                setStates = arr;
                            }
                        }

                        Text {
                            text: "Set " + (index + 1)
                            font.pixelSize: 14
                            font.bold: true
                            color: modelData.done ? "#4caf50" : "#333"
                            Layout.preferredWidth: 60
                        }

                        Text {
                            text: modelData.reps + " reps"
                            font.pixelSize: 13
                            color: modelData.done ? "#aaa" : "#555"
                            Layout.fillWidth: true
                        }

                        Controls.SpinBox {
                            id: repSpin
                            from: 1
                            to: 99
                            value: modelData.reps
                            enabled: !modelData.done
                            Layout.preferredWidth: 80
                            onValueChanged: {
                                if (repSpin.value !== modelData.reps) {
                                    var arr = setStates.slice();
                                    arr[index] = { done: arr[index].done, reps: repSpin.value };
                                    setStates = arr;
                                }
                            }
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

            // Navigation
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 12
                spacing: 10

                Controls.Button {
                    text: "Complete"
                    Layout.fillWidth: true
                    onClicked: {
                        var arr = [];
                        for (var i = 0; i < setStates.length; i++)
                            arr.push({ done: true, reps: setStates[i].reps });
                        setStates = arr;
                        if (currentWorkoutIndex === planWorkouts.length - 1) {
                            timerRunning = false;
                            applicationWindow().pageStack.pop();
                        } else {
                            goNext();
                        }
                    }
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
                            timerRunning = false;
                            applicationWindow().pageStack.pop();
                        } else {
                            goNext();
                        }
                    }
                }
            }
        }
    }
}
