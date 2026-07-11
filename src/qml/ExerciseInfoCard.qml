import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    property var exercise: ({})

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
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: exercise.gifUrl || ""
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
                text: exercise.name ? exercise.name.charAt(0).toUpperCase() + exercise.name.slice(1) : ""
                font.pixelSize: 18
                font.bold: true
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6
                visible: exercise.equipments && exercise.equipments.length > 0

                Rectangle {
                    radius: 4
                    color: Qt.rgba(Kirigami.Theme.positiveColor.r, Kirigami.Theme.positiveColor.g, Kirigami.Theme.positiveColor.b, 0.12)
                    Layout.preferredWidth: equipTag.implicitWidth + 12
                    Layout.preferredHeight: 20

                    Text {
                        id: equipTag
                        anchors.centerIn: parent
                        text: exercise.equipments ? exercise.equipments.charAt(0).toUpperCase() + exercise.equipments.slice(1) : ""
                        font.pixelSize: 10
                        color: Kirigami.Theme.positiveColor
                    }
                }
            }

            Text {
                text: exercise.bodyParts ? exercise.bodyParts.charAt(0).toUpperCase() + exercise.bodyParts.slice(1) : ""
                font.pixelSize: 12
                color: Kirigami.Theme.disabledTextColor
            }

            Text {
                text: exercise.targetMuscles ? exercise.targetMuscles.charAt(0).toUpperCase() + exercise.targetMuscles.slice(1) : ""
                font.pixelSize: 12
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }
}
