import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Kirigami.Page {
    Rectangle {
        anchors.fill: parent
        color: "lightgreen"
        Controls.Button {
            anchors.centerIn: parent
            text: "Pop!"
            onClicked: applicationWindow().pageStack.pop()
        }
    }
}
