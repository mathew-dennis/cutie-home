import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtMultimedia
import Cutie
import Cutie.Feedback
import Cutie.Store
import Cutie.Wlc
import Cutie.Desktopfileparser

Item {
    id: root
    state: "homeScreen"
    visible: true
    width: Screen.width
    height: Screen.height

    // Global property to control all thumbnails
    property bool thumbnailsFrozen: state !== "appSwitcher"
    
    onStateChanged: {
        // Freeze thumbnails when leaving appSwitcher, resume when entering
        if (state === "appSwitcher")
            thumbnailsFrozen = false
        else
            thumbnailsFrozen = true
    }
    
    states: [
        State {
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
        console.log("home - Loading Favorite store data...");
        
        // Check if data exists; if not or if empty, inject defaults
        let currentData = favoriteStore.data || {};
        let favoriteKeys = Object.keys(currentData);

        if (favoriteKeys.length === 0) {
            console.log("home - Favorite store is empty. Setting defaults: terminal, browser, settings.");
            favoriteStore.data = {
                "terminal": "terminal",
                "browser": "browser",
                "settings": "settings",
                "visibility": true
            };
            return; // Setting data will trigger onDataChanged, which calls this function again
        }

        launcherApps.clear();
        let allAppsModel = CutieDesktopFileParser.fetchAllEntriesModel();
        
        if (!allAppsModel) {
            console.log("home - Error: DesktopFileParser model is null.");
            return;
        }

        for (let i = 0; i < allAppsModel.rowCount(); i++) {
            let index = allAppsModel.index(i, 0);
            let appName = allAppsModel.data(index, 257);
            
            if (currentData.hasOwnProperty(appName)) {
                launcherApps.append({
                    name: appName,
                    icon: allAppsModel.data(index, 259),
                    exec: allAppsModel.data(index, 258)
                });
            }
        }
        console.log("home - Favorite apps loaded successfully. Count:", launcherApps.count);
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
            console.log("home - Visibility updated. Current state:", favoriteAppsVisibility);
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
