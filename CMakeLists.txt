cmake_minimum_required(VERSION 3.16)
project(cutie-home VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

include( GNUInstallDirs )

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Network Qml DBus)
find_package(LayerShellQt6 REQUIRED)

set(cutie-home_SOURCES 
    src/settings.cpp 
    src/notifications.cpp 
    src/settings.h 
    src/notifications.h 
    src/main.cpp 
    src/launcher.cpp
    src/launcher.h
)

qt6_add_resources(APP_RESOURCES 
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qml/qml.qrc)

qt_add_dbus_interface(cutie-home_SOURCES src/org.freedesktop.DBus.xml dbus_interface)
qt_add_dbus_interface(cutie-home_SOURCES src/org.freedesktop.Notifications.xml notifications_interface)
qt_add_dbus_adaptor(cutie-home_SOURCES src/org.freedesktop.Notifications.xml notifications.h Notifications NotificationsAdaptor)

qt_add_executable(cutie-home ${cutie-home_SOURCES} ${APP_RESOURCES})

target_include_directories(cutie-home  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(cutie-home PUBLIC LayerShellQtInterface6 Qt::Core Qt::Gui Qt::GuiPrivate Qt::DBus Qt::Quick Qt::Network Qt::Qml)

install(TARGETS cutie-home RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
