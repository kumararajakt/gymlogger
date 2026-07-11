import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    property bool reminderEnabled: false
    property var reminderDays: []
    property string reminderTime: "08:00"

    signal reminderToggled(bool enabled)
    signal dayToggled(string day)

    Layout.fillWidth: true
    Layout.leftMargin: 16
    Layout.rightMargin: 16
    spacing: 10

    RowLayout {
        Text {
            text: "Reminder"
            font.bold: true
            font.pixelSize: 13
            color: "#666"
        }
        Item { Layout.fillWidth: true }
        Controls.CheckBox {
            checked: root.reminderEnabled
            onCheckedChanged: root.reminderToggled(checked)
        }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 6
        enabled: root.reminderEnabled
        opacity: enabled ? 1.0 : 0.4

        Repeater {
            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            Controls.Button {
                text: modelData
                checkable: true
                checked: root.reminderDays.indexOf(modelData) >= 0
                onClicked: root.dayToggled(modelData)
            }
        }
    }

    RowLayout {
        spacing: 8
        Layout.topMargin: 4
        enabled: root.reminderEnabled
        opacity: enabled ? 1.0 : 0.4

        Text {
            text: "Time"
            font.pixelSize: 13
            color: "#666"
        }

        Controls.SpinBox {
            id: hourSpin
            from: 0
            to: 23
            value: parseInt(root.reminderTime.split(":")[0]) || 8
            onValueChanged: {
                var min = minuteSpin.value;
                root.reminderTime = (value < 10 ? "0" : "") + value + ":" + (min < 10 ? "0" : "") + min;
            }
        }

        Text {
            text: ":"
            font.pixelSize: 16
            font.bold: true
        }

        Controls.SpinBox {
            id: minuteSpin
            from: 0
            to: 59
            stepSize: 5
            value: parseInt(root.reminderTime.split(":")[1]) || 0
            onValueChanged: {
                var hr = hourSpin.value;
                root.reminderTime = (hr < 10 ? "0" : "") + hr + ":" + (value < 10 ? "0" : "") + value;
            }
        }
    }
}
