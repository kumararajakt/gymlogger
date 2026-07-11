import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: detailPage
    padding: 0

    property var exercise: ({})

    title: exercise.name ? exercise.name.charAt(0).toUpperCase() + exercise.name.slice(1) : "Exercise"

    function parseArray(val) {
        if (!val) return []
        if (Array.isArray(val)) return val
        if (typeof val === "string" && val.length > 0) return val.split(",")
        return []
    }

    Flickable {
        anchors.fill: parent
        contentHeight: detailContent.height
        clip: true
        Controls.ScrollBar.vertical: Controls.ScrollBar {}

        ColumnLayout {
            id: detailContent
            width: parent.width
            spacing: 16

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                Layout.margins: 16

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.03)

                    Image {
                        anchors.fill: parent
                        anchors.margins: 8
                        source: exercise.gifUrl || ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true

                        Controls.BusyIndicator {
                            anchors.centerIn: parent
                            running: parent.status === Image.Loading
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Controls.Label {
                    text: "Body Part"
                    font.bold: true
                    font.pixelSize: 13
                }
                Controls.Label {
                    text: exercise.bodyParts || ""
                    font.pixelSize: 15
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Controls.Label {
                    text: "Target Muscles"
                    font.bold: true
                    font.pixelSize: 13
                }
                Controls.Label {
                    text: exercise.targetMuscles || ""
                    font.pixelSize: 15
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4
                visible: exercise.secondaryMuscles && exercise.secondaryMuscles.length > 0

                Controls.Label {
                    text: "Secondary Muscles"
                    font.bold: true
                    font.pixelSize: 13
                }
                Controls.Label {
                    text: exercise.secondaryMuscles || ""
                    font.pixelSize: 15
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 4

                Controls.Label {
                    text: "Equipment"
                    font.bold: true
                    font.pixelSize: 13
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: parseArray(exercise.equipments)
                        Rectangle {
                            radius: 12
                            color: Qt.rgba(0.2, 0.6, 1.0, 0.1)
                            width: equipTag.implicitWidth + 16
                            height: 28

                            Controls.Label {
                                id: equipTag
                                anchors.centerIn: parent
                                text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 16
                spacing: 8

                Controls.Label {
                    text: "Instructions"
                    font.bold: true
                    font.pixelSize: 13
                }

                Repeater {
                    model: exercise.instructions ? exercise.instructions.split("\n").filter(function(s) { return s.length > 0; }) : []
                    Controls.Label {
                        Layout.fillWidth: true
                        text: modelData
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        lineHeight: 1.4
                    }
                }
            }
        }
    }
}
