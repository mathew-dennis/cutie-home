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
            PropertyChanges { target: appSwitcher; opacity: 1 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
        },
        State {
            name: "notificationScreen"
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

    AppSwitcher { id: appSwitcher }
    NotificationScreen { id: notificationScreen }
    ScreenSwipe { id: screenSwipe }
    
    SoundEffect {
        id: notifSound
        source: "qrc:/sounds/notif.wav"
    }

    ListModel { id: notifications }
}
