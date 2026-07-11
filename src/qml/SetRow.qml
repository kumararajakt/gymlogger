import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: root

    property bool done: false
    property int setNumber: 0
    property int reps: 8

    signal toggled(bool checked)
    signal repsModified(int newReps)

    Layout.fillWidth: true
    spacing: 10

    Controls.CheckBox {
        checked: root.done
        onCheckedChanged: root.toggled(checked)
    }

    Text {
        text: "Set " + root.setNumber
        font.pixelSize: 14
        font.bold: true
        color: root.done ? Kirigami.Theme.positiveColor : Kirigami.Theme.textColor
        Layout.preferredWidth: 60
    }

    Text {
        text: root.reps + " reps"
        font.pixelSize: 13
        color: root.done ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
        Layout.fillWidth: true
    }

    Controls.SpinBox {
        id: repSpin
        from: 1
        to: 99
        value: root.reps
        enabled: !root.done
        Layout.preferredWidth: 80
        onValueChanged: {
            if (repSpin.value !== root.reps)
                root.repsModified(repSpin.value)
        }
    }
}
