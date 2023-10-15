import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtMultimedia
import QtSensors

import Cutie

Item {
    id: root
    state: "appSwitcher" 
    visible: true
    width: Screen.width
    height: Screen.height

    states: [
        State{
            name: "appSwitcher"
            PropertyChanges { target: wallpaperBlur; opacity: 0 }
            PropertyChanges { target: appSwitcher; opacity: 1 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
        },
        State {
            name: "notificationScreen"
            PropertyChanges { target: wallpaperBlur; opacity: 1 }
            PropertyChanges { target: appSwitcher; opacity: 0 }
            PropertyChanges { target: notificationScreen; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { target: notificationScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: appSwitcher; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
        }

    ]

    function addNotification(title, body, id) {
        notifications.append({title: title, body: body, id: id});
        notifSound.play();
    }

    function delNotification(id) {
        for (let c_i = 0; c_i < notifications.count; c_i++){
            if (notifications.get(c_i).id === id)
                notifications.remove(c_i);
        }
    }

    Item {
        id: realWallpaper
        anchors.fill: parent

        Image {
            id: wallpaper
            anchors.fill: parent
            source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            id: nextWallpaper
            anchors.fill: parent
            source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
            fillMode: Image.PreserveAspectCrop
            opacity: 0
            state: "normal"
            states: [
                State {
                    name: "changing"
                    PropertyChanges { target: nextWallpaper; opacity: 1 }
                },
                State {
                    name: "normal"
                    PropertyChanges { target: nextWallpaper; opacity: 0 }
                }
            ]

            transitions: Transition {
                to: "normal"

                NumberAnimation {
                    target: nextWallpaper
                    properties: "opacity"
                    easing.type: Easing.InOutQuad
                    duration: 500
                }
            }
        }
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        source: realWallpaper
        radius: 70

        Behavior on opacity {
            PropertyAnimation { duration: 300 }
        }
    }

    Rectangle {
        color: Atmosphere.secondaryAlphaColor
        anchors.fill: wallpaperBlur
        opacity: wallpaperBlur.opacity / 3
    }

    AppSwitcher { id: appSwitcher }
    NotificationScreen { id: notificationScreen }
    ScreenSwipe { id: screenSwipe }
    
    SoundEffect {
        id: notifSound
        source: "qrc:/sounds/notif.wav"
    }

    ListModel { id: notifications }
}
