import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: planPage
    padding: 0

    title: "Plans"

    header: RowLayout {
        width: parent.width
        height: 50

        Item { Layout.fillWidth: true }

        Controls.ToolButton {
            icon.name: "list-add"
            onClicked: applicationWindow().pageStack.push(Qt.resolvedUrl("AddPlanPage.qml"))
        }
    }

    property var planModel: applicationWindow().planModel

    ListView {
        anchors.fill: parent
        model: planModel
        clip: true
        spacing: 0
        visible: planModel.count > 0

        delegate: Rectangle {
            width: ListView.view.width
            height: 80
            color: "white"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 22
                    color: Qt.rgba(0.2, 0.6, 1.0, 0.1)

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        source: "view-calendar"
                        width: 22
                        height: 22
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: model.planName
                        font.bold: true
                        font.pixelSize: 15
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        text: model.planWorkouts.length + " workout" + (model.planWorkouts.length !== 1 ? "s" : "")
                        font.pixelSize: 12
                        color: "#888"
                    }

                    RowLayout {
                        spacing: 4
                        visible: model.reminderDays.length > 0

                        Kirigami.Icon {
                            source: "notifications"
                            width: 12
                            height: 12
                        }

                        Text {
                            text: model.reminderDays.join(", ") + (model.reminderTime.length > 0 ? "  " + model.reminderTime : "")
                            font.pixelSize: 11
                            color: "#666"
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                Controls.ToolButton {
                    icon.name: "delete"
                    onClicked: planModel.removePlan(model.planId)
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                anchors.leftMargin: 72
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

        Text {
            text: "No plans yet"
            font.pixelSize: 18
            font.bold: true
            color: "#999"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
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
