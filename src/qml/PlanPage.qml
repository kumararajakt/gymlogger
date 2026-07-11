import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: planPage
    padding: 0

    title: "Plans"

    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            onTriggered: applicationWindow().pageStack.push(Qt.resolvedUrl("AddPlanPage.qml"))
        }
    ]

    property var planModel: applicationWindow().planModel

    ListView {
        id: planList
        anchors.fill: parent
        model: planModel
        clip: true

        delegate: Controls.ItemDelegate {
            width: parent.width
            onClicked: applicationWindow().pageStack.push(Qt.resolvedUrl("EditPlanPage.qml"), { planId: model.planId })

            contentItem: RowLayout {
                width: parent.width

                ColumnLayout {
                    Layout.fillWidth: true
                    Controls.Label {
                        text: model.planName
                        font.bold: true
                        font.pixelSize: 15
                        elide: Text.ElideRight
                    }

                    Controls.Label {
                        text: model.planWorkouts.length + " workout" + (model.planWorkouts.length !== 1 ? "s" : "") + " •" + model.reminderDays.join(", ") + " " + model.reminderTime
                        elide: Text.ElideRight
                    }
                }

                Controls.ToolButton {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    icon.name: "delete"
                    onClicked: planModel.removePlan(model.planId)
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        visible: planModel.count === 0

        Kirigami.Icon {
            source: "view-calendar"
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignHCenter
            color: "#ccc"
        }

        Controls.Label {
            text: "No plans yet"
            font.pixelSize: 18
            font.bold: true
            color: "#999"
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.Label {
            text: "Create a workout plan to get started"
            font.pixelSize: 13
            color: "#bbb"
            Layout.alignment: Qt.AlignHCenter
        }

        Controls.Button {
            text: "Create Plan"
            Layout.alignment: Qt.AlignHCenter
            onClicked: applicationWindow().pageStack.push(Qt.resolvedUrl("AddPlanPage.qml"))
        }
    }
}
