import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.tutorial
import "ExerciseDb.js" as ExerciseDb

Kirigami.Page {
    id: workoutPage
    padding: 0

    property ExerciseModel exerciseModel: ExerciseModel {}
    property var bodyPartModel: ListModel {}
    property var equipmentModel: ListModel {}
    property string searchQuery: ""
    property string selectedBodyPart: ""
    property bool busy: false
    property bool canLoadMore: false
    property int pageLimit: 20
    property string nextCursor: ""
    property bool selectMode: false
    property var planWorkouts: []

    signal selectionDone(var selectedItems)

    title: selectMode ? "Select Workouts" : "Workouts"

    header: RowLayout {
        width: parent.width
        height: 50
        visible: selectMode

        Item { Layout.fillWidth: true }

        Controls.Button {
            text: "Done"
            onClicked: {
                            workoutPage.selectionDone(planWorkouts)
                applicationWindow().pageStack.pop()
            }
        }
    }

    function isExerciseSelected(exerciseId) {
        for (var i = 0; i < planWorkouts.length; i++) {
            if (planWorkouts[i].exerciseId === exerciseId) return true
        }
        return false
    }

    function toggleExerciseSelection(exercise) {
        var arr = []
        var found = false
        for (var i = 0; i < planWorkouts.length; i++) {
            if (planWorkouts[i].exerciseId === exercise.exerciseId) {
                found = true
                continue
            }
            arr.push(planWorkouts[i])
        }
        if (!found) {
            arr.push(exercise)
        }
        planWorkouts = arr
    }

    function normalizeExercise(item) {
        return {
            exerciseId: item.exerciseId || "",
            name: item.name || "",
            gifUrl: item.gifUrl || "",
            bodyParts: Array.isArray(item.bodyParts) ? item.bodyParts.join(",") : (item.bodyParts || ""),
            targetMuscles: Array.isArray(item.targetMuscles) ? item.targetMuscles.join(",") : (item.targetMuscles || ""),
            secondaryMuscles: Array.isArray(item.secondaryMuscles) ? item.secondaryMuscles.join(",") : (item.secondaryMuscles || ""),
            equipments: Array.isArray(item.equipments) ? item.equipments.join(",") : (item.equipments || ""),
            instructions: Array.isArray(item.instructions) ? item.instructions.join("\n") : (item.instructions || "")
        }
    }

    function loadExercises() {
        busy = true
        var params = { limit: pageLimit }
        if (searchQuery.length > 0) params.name = searchQuery
        if (selectedBodyPart.length > 0) params.bodyParts = selectedBodyPart

        ExerciseDb.fetchExercises(params).then(function(result) {
            exerciseModel.clear()
            var items = result.data || []
            for (var i = 0; i < items.length; i++) {
                exerciseModel.addExercise(normalizeExercise(items[i]))
            }
            canLoadMore = result.meta.hasNextPage === true
            nextCursor = result.meta.nextCursor || ""
            exerciseGrid.positionViewAtBeginning()
            busy = false
        }).catch(function(err) {
            console.error("Failed to load exercises:", err)
            busy = false
        })
    }

    function loadMoreExercises() {
        if (!canLoadMore || busy) return
        busy = true
        var params = { limit: pageLimit, after: nextCursor }
        if (searchQuery.length > 0) params.name = searchQuery
        if (selectedBodyPart.length > 0) params.bodyParts = selectedBodyPart

        ExerciseDb.fetchExercises(params).then(function(result) {
            var items = result.data || []
            for (var i = 0; i < items.length; i++) {
                exerciseModel.addExercise(normalizeExercise(items[i]))
            }
            canLoadMore = result.meta.hasNextPage === true
            nextCursor = result.meta.nextCursor || ""
            busy = false
        }).catch(function(err) {
            console.error("Failed to load more:", err)
            busy = false
        })
    }

    function searchExercises(term) {
        busy = true
        ExerciseDb.searchExercises(term).then(function(result) {
            exerciseModel.clear()
            var items = result || []
            for (var i = 0; i < items.length; i++) {
                exerciseModel.addExercise(normalizeExercise(items[i]))
            }
            canLoadMore = false
            exerciseGrid.positionViewAtBeginning()
            busy = false
        }).catch(function(err) {
            console.error("Search failed:", err)
            busy = false
        })
    }

    function loadBodyParts() {
        ExerciseDb.fetchBodyParts().then(function(result) {
            bodyPartModel.clear()
            var items = result.data || []
            for (var i = 0; i < items.length; i++) {
                bodyPartModel.append(items[i])
            }
        }).catch(function(err) {
            console.error("Failed to load body parts:", err)
        })
    }

    function loadEquipments() {
        ExerciseDb.fetchEquipments().then(function(result) {
            equipmentModel.clear()
            var items = result.data || []
            for (var i = 0; i < items.length; i++) {
                equipmentModel.append(items[i])
            }
        }).catch(function(err) {
            console.error("Failed to load equipments:", err)
        })
    }

    function toggleBodyPartFilter(part) {
        searchQuery = ""
        searchField.text = ""
        if (selectedBodyPart === part) {
            selectedBodyPart = ""
        } else {
            selectedBodyPart = part
        }
        loadExercises()
    }

    Component.onCompleted: {
        loadExercises()
        loadBodyParts()
        loadEquipments()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Qt.rgba(0, 0, 0, 0.05)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Kirigami.Icon {
                    source: "edit-find"
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                }

                Controls.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Search exercises..."
                    onAccepted: {
                        selectedBodyPart = ""
                        if (text.length > 0) {
                            searchExercises(text)
                        } else {
                            loadExercises()
                        }
                    }
                }

                Controls.Button {
                    text: "X"
                    implicitWidth: 30
                    implicitHeight: 30
                    visible: searchField.text.length > 0
                    onClicked: {
                        searchField.text = ""
                        searchQuery = ""
                        loadExercises()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"

            ListView {
                id: bodyPartFilter
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                orientation: ListView.Horizontal
                spacing: 6
                clip: true
                model: bodyPartModel

                delegate: Controls.Button {
                    height: 30
                    text: model.name.charAt(0).toUpperCase() + model.name.slice(1)
                    checkable: true
                    checked: selectedBodyPart === model.name
                    onClicked: toggleBodyPartFilter(model.name)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(0, 0, 0, 0.1)
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridView {
                id: exerciseGrid
                anchors.fill: parent
                anchors.margins: 8
                property int columns: Math.max(2, Math.floor(width / 160))
                cellWidth: width / columns
                cellHeight: 200
                model: exerciseModel
                clip: true

                delegate: Item {
                    width: exerciseGrid.cellWidth
                    height: exerciseGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 8
                        color: "white"
                        border.color: Qt.rgba(0, 0, 0, 0.1)
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Image {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                source: model.gifUrl || ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: true

                                Controls.BusyIndicator {
                                    anchors.centerIn: parent
                                    running: parent.status === Image.Loading
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.name ? model.name.charAt(0).toUpperCase() + model.name.slice(1) : ""
                                font.bold: true
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    radius: 4
                                    color: Qt.rgba(0.2, 0.6, 1.0, 0.15)
                                    Layout.preferredWidth: bodyPartLabel.implicitWidth + 12
                                    Layout.preferredHeight: 18

                                    Text {
                                        id: bodyPartLabel
                                        anchors.centerIn: parent
                                        text: model.bodyParts ? model.bodyParts.charAt(0).toUpperCase() + model.bodyParts.slice(1) : ""
                                        font.pixelSize: 9
                                        color: "#1a73e8"
                                    }
                                }

                                Rectangle {
                                    radius: 4
                                    color: Qt.rgba(0.0, 0.7, 0.3, 0.15)
                                    Layout.preferredWidth: equipLabel.implicitWidth + 12
                                    Layout.preferredHeight: 18
                                    visible: model.equipments && model.equipments.length > 0

                                    Text {
                                        id: equipLabel
                                        anchors.centerIn: parent
                                        text: model.equipments ? model.equipments.charAt(0).toUpperCase() + model.equipments.slice(1) : ""
                                        font.pixelSize: 9
                                        color: "#0d7d3b"
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (selectMode) {
                                    toggleExerciseSelection({
                                        exerciseId: model.exerciseId,
                                        name: model.name,
                                        gifUrl: model.gifUrl,
                                        bodyParts: model.bodyParts,
                                        targetMuscles: model.targetMuscles,
                                        secondaryMuscles: model.secondaryMuscles,
                                        equipments: model.equipments,
                                        instructions: model.instructions
                                    })
                                } else {
                                    applicationWindow().pageStack.push(Qt.resolvedUrl("WorkoutDetailPage.qml"), {
                                        exercise: {
                                            exerciseId: model.exerciseId,
                                            name: model.name,
                                            gifUrl: model.gifUrl,
                                            bodyParts: model.bodyParts,
                                            targetMuscles: model.targetMuscles,
                                            secondaryMuscles: model.secondaryMuscles,
                                            equipments: model.equipments,
                                            instructions: model.instructions
                                        }
                                    })
                                }
                            }
                        }

                        Rectangle {
                            visible: selectMode && isExerciseSelected(model.exerciseId)
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: 24
                            height: 24
                            radius: 12
                            color: "#4caf50"

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                source: "checkmark"
                                width: 14
                                height: 14
                                color: "white"
                            }
                        }
                    }
                }

                footer: Item {
                    width: exerciseGrid.width
                    height: 50

                    Controls.Button {
                        anchors.centerIn: parent
                        text: canLoadMore ? "Load More" : "No more exercises"
                        enabled: canLoadMore && !busy
                        onClicked: loadMoreExercises()
                    }
                }
            }

            Controls.BusyIndicator {
                anchors.centerIn: parent
                running: busy
                visible: running
                width: 48
                height: 48
            }

            Text {
                anchors.centerIn: parent
                text: "No exercises found"
                font.pixelSize: 16
                color: "#999"
                visible: !busy && exerciseModel.count === 0
            }
        }
    }
}
