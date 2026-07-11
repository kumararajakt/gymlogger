import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var exercise: ({})
    property bool selected: false
    property bool selectMode: false

    signal clicked()
    signal toggleSelection(var exercise)

    width: cellWidth
    height: cellHeight

    property real cellWidth: 160
    property real cellHeight: 200

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
                source: exercise.gifUrl || ""
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
                text: exercise.name ? exercise.name.charAt(0).toUpperCase() + exercise.name.slice(1) : ""
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
                        text: exercise.bodyParts ? exercise.bodyParts.charAt(0).toUpperCase() + exercise.bodyParts.slice(1) : ""
                        font.pixelSize: 9
                        color: "#1a73e8"
                    }
                }

                Rectangle {
                    radius: 4
                    color: Qt.rgba(0.0, 0.7, 0.3, 0.15)
                    Layout.preferredWidth: equipLabel.implicitWidth + 12
                    Layout.preferredHeight: 18
                    visible: exercise.equipments && exercise.equipments.length > 0

                    Text {
                        id: equipLabel
                        anchors.centerIn: parent
                        text: exercise.equipments ? exercise.equipments.charAt(0).toUpperCase() + exercise.equipments.slice(1) : ""
                        font.pixelSize: 9
                        color: "#0d7d3b"
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Rectangle {
            visible: selectMode && selected
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
