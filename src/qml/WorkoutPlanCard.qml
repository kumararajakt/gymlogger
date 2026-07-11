import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var workoutData: ({})
    property int workoutIndex: -1
    property bool syncing: false

    signal removeRequested(int workoutIndex)
    signal moveUpRequested(int workoutIndex)
    signal moveDownRequested(int workoutIndex)
    signal fieldChanged(int workoutIndex, string fieldName, var fieldValue)
    signal reorderRequested(int fromIndex, int toIndex)

    implicitWidth: 320
    implicitHeight: cardColumn.implicitHeight + 16

    property int setsValue: 4
    property int repsValue: 8
    property int weightValue: 16
    property int restValue: 75
    property bool expanded: false

    function toInt(value, fallback) {
        var parsed = parseInt(value);
        return isNaN(parsed) ? fallback : parsed;
    }

    function syncFromWorkout() {
        syncing = true;
        setsValue = toInt(workoutData.sets, 4);
        repsValue = toInt(workoutData.reps, 8);
        weightValue = toInt(workoutData.weight, 16);
        restValue = toInt(workoutData.rest, 75);
        expanded = workoutData.expanded === true;
        syncing = false;
    }

    function updateWorkoutField(name, value) {
        if (!workoutData)
            return;
        root.fieldChanged(workoutIndex, name, value);
    }

    function toggleExpanded() {
        expanded = !expanded;
        updateWorkoutField("expanded", expanded);
    }

    Component.onCompleted: syncFromWorkout()
    onWorkoutDataChanged: syncFromWorkout()

    Drag.active: dragArea.pressed
    Drag.source: root
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    states: [
        State {
            when: dragArea.pressed
            PropertyChanges { target: root; opacity: 0.7 }
            PropertyChanges { target: cardColumn; anchors.horizontalCenter: undefined }
        }
    ]

    DropArea {
        anchors.fill: parent
        anchors.margins: 4

        onEntered: function(drag) {
            var fromIndex = drag.source.workoutIndex;
            var toIndex = root.workoutIndex;
            if (fromIndex !== toIndex)
                root.reorderRequested(fromIndex, toIndex);
        }
    }

    ColumnLayout {
        id: cardColumn
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Kirigami.Icon {
                source: "handle-sort"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    cursorShape: Qt.OpenHandCursor
                    drag.target: root
                    drag.axis: Drag.YAxis
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Controls.Label {
                    text: workoutData.name || ""
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Controls.Label {
                    text: setsValue + " sets x " + repsValue + " reps"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Controls.ToolButton {
                text: expanded ? "⌃" : "⌄"
                font.pixelSize: 18
                onClicked: toggleExpanded()
            }

            Controls.ToolButton {
                text: "X"
                font.pixelSize: 13
                onClicked: root.removeRequested(workoutIndex)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: expanded
            spacing: 10

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Controls.Label {
                        text: "Sets"
                        font.pixelSize: 11
                    }

                    Controls.SpinBox {
                        Layout.fillWidth: true
                        from: 1
                        to: 99
                        value: setsValue
                        onValueChanged: {
                            setsValue = value;
                            if (!syncing)
                                updateWorkoutField("sets", value);
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Controls.Label {
                        text: "Reps"
                        font.pixelSize: 11
                    }

                    Controls.SpinBox {
                        Layout.fillWidth: true
                        from: 1
                        to: 99
                        value: repsValue
                        onValueChanged: {
                            repsValue = value;
                            if (!syncing)
                                updateWorkoutField("reps", value);
                        }
                    }
                }
            }
        }
    }
}
