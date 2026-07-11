cmake_minimum_required(VERSION 3.20)
project(gymlogger)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(ECMQmlModule)
include(ECMAddAndroidApk)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    Test
    Gui
    QuickControls2
    Sql
)

find_package(KF6 REQUIRED COMPONENTS
    Kirigami
    I18n
    CoreAddons
    IconThemes
)

if(NOT ANDROID)
    find_package(KF6 REQUIRED COMPONENTS QQC2DesktopStyle)
    find_package(Qt6 REQUIRED COMPONENTS Widgets)
endif()

ecm_find_qmlmodule(org.kde.kirigami REQUIRED)

add_subdirectory(src)

ecm_add_android_apk(gymlogger ANDROID_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android)

install(PROGRAMS gymlogger.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES src/icons/hicolor/scalable/apps/gymlogger.svg
    DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
