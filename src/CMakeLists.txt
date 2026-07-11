add_executable(gymlogger)

ecm_add_qml_module(gymlogger
    URI
    org.kde.tutorial
)

target_sources(gymlogger
    PRIVATE
    main.cpp
    PlanModel.cpp
    PlanModel.h
    SessionModel.cpp
    SessionModel.h
    ExerciseModel.cpp
    ExerciseModel.h
)

ecm_target_qml_sources(gymlogger
    SOURCES
    qml/Main.qml
    qml/PlanPage.qml
    qml/LogPage.qml
    qml/WorkoutPage.qml
    qml/WorkoutDetailPage.qml
    qml/AddPlanPage.qml
    qml/EditPlanPage.qml
    qml/ActiveWorkoutPage.qml
    qml/WorkoutPlanCard.qml
    qml/ActiveTimerSection.qml
    qml/ExerciseInfoCard.qml
    qml/SetRow.qml
    qml/ExerciseGridCard.qml
    qml/ReminderSection.qml
    qml/CalendarGrid.qml
    qml/PlanWorkoutUtils.js
    qml/ExerciseDb.js
)

target_link_libraries(gymlogger
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Sql
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

if(NOT ANDROID)
    target_link_libraries(gymlogger PRIVATE Qt6::Widgets)
endif()

install(TARGETS gymlogger ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
