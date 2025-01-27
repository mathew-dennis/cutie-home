import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtMultimedia
import Cutie
import Cutie.Feedback
import Cutie.Store
import Cutie.Wlc

Item {
    id: root
    state: "homeScreen" 
    visible: true
    width: Screen.width
    height: Screen.height

    states: [
        State{
            name: "appSwitcher"
            PropertyChanges { target: appSwitcher; opacity: 1 }
            PropertyChanges { target: homeScreen; opacity: 0 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
        },
        State {
            name: "homeScreen"
            PropertyChanges { target: appSwitcher; opacity: 0 }
            PropertyChanges { target: homeScreen; opacity: 1 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
        },
        State {
            name: "notificationScreen"
            PropertyChanges { target: appSwitcher; opacity: 0 }
            PropertyChanges { target: homeScreen; opacity: 0 }
            PropertyChanges { target: notificationScreen; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { target: notificationScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: homeScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: appSwitcher; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
        }

    ]

    function addNotification(title, body, id) {
        notifications.append({title: title, body: body, id: id});
        CutieFeedback.trigger(Application.name, "message-new-instant", {}, -1);
    }

    function delNotification(id) {
        for (let c_i = 0; c_i < notifications.count; c_i++){
            if (notifications.get(c_i).id === id)
                notifications.remove(c_i);
        }
    }

    function loadFavoriteApps() {
        console.log("loadin Favorite store data ");
        if (!favoriteStore.data) {
            console.log("Favorite store data is not yet available.");
            return;
        }
        let favoriteData = favoriteStore.data;
        launcherApps.clear(); 
        console.log("Favorite store data:", JSON.stringify(favoriteData));

        
        for (let key in favoriteData) {
           if (key.startsWith("favoriteApp-")) {
                console.log("found Favorite store data entry ");
                let appData = favoriteData[key];
                let data = { 
                    "Desktop Entry/Name": key.substring(12), 
                    "Desktop Entry/Icon": appData.icon, 
                    "Desktop Entry/Exec": appData.command 
                };
                console.log("Appending data:", JSON.stringify(data));
                launcherApps.append(data);
            }
        }

        console.log("Favorite apps loaded successfully.");
        console.log("Current launcherApps contents:", JSON.stringify(launcherApps));
        console.log("Number of items in launchAppList:", launchAppGrid.count);
    }

    Component.onCompleted: {
        loadFavoriteApps();
        updateVisibility();
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"

        onDataChanged: {
            loadFavoriteApps();
            updateVisibility();
        }
    }

    property bool favoriteAppsVisibility: "visibility" in favoriteStore.data ? favoriteStore.data["visibility"] : true
    
    function updateVisibility() {
        if (favoriteStore.data) {
            let favoriteData = favoriteStore.data;

            favoriteAppsVisibility = favoriteData.visibility;
            console.log("home: Visibility variable updated . Current state:", favoriteAppsVisibility);
            favoriteStore.data = favoriteData;
        }
    }

    ForeignToplevelManagerV1 {
        id: toplevelManager
    }

    CutieWlc {
        id: cutieWlc
    }

    Image {
        id: wallpaper
        width: Screen.width
        height: Screen.height
        source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        visible: true
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: wallpaper
        source: wallpaper
        radius: 70
        visible: true
        opacity: Math.max(cutieWlc.blur, notificationScreen.opacity)
    }

    AppSwitcher { id: appSwitcher }
    NotificationScreen { id: notificationScreen }
    ScreenSwipe { id: screenSwipe }
    HomeScreen { id: homeScreen }

    ListModel { id: notifications }
    ListModel { id: launcherApps }
}
