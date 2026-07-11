import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.tutorial

Kirigami.ApplicationWindow {
    width: 400
    height: 700
    visible: true

    property PlanModel planModel: PlanModel {}
    property SessionModel sessionModel: SessionModel {}

    pageStack.initialPage: page1

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                text: "Logs"
                icon.name: "go-home"
                onTriggered: pageStack.replace(page1)
            },
            Kirigami.Action {
                text: "Plans"
                icon.name: "run-build"
                onTriggered: pageStack.replace(planPage)
            },
            Kirigami.Action {
                text: "Workouts"
                icon.name: "settings-configure"
                onTriggered: pageStack.replace(workoutPage)
            }
        ]
    }

    Component { id: page1; LogPage {} }
    Component { id: planPage; PlanPage {} }
    Component { id: workoutPage; WorkoutPage {} }
}
