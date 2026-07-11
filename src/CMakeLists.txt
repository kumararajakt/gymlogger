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
    qml/ExerciseDb.js
)

target_link_libraries(gymlogger
    PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::Sql
    KF6::I18n
    KF6::CoreAddons
    KF6::IconThemes
)

install(TARGETS gymlogger ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
