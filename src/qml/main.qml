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
        console.log("Loading Favorite store data using DesktopFileParser...");
        if (!favoriteStore.data) {
            console.log("Favorite store data is not yet available.");
            return;
        }

        let favoriteData = favoriteStore.data;
        launcherApps.clear();

        // Print all favorite keys for debugging
        let favoriteKeys = Object.keys(favoriteData);
        console.log("favoriteData keys:", favoriteKeys);

        // Normalize favorite keys for robust comparison
        let normalizedFavoriteKeys = favoriteKeys.map(k => k.trim().toLowerCase());

        // Get the C++ model instance. Explicitly passing [] to resolve overload.
        let allAppsModel = CutieDesktopFileParser.fetchAllEntriesModel();
        if (!allAppsModel) {
            console.log("Error: DesktopFileParser model is null.");
            return;
        }

        console.log("allAppsModel received count:", allAppsModel.rowCount());
        console.log("Role names:", allAppsModel.roleNames ? allAppsModel.roleNames() : "No roleNames function");

        // Iterate through the C++ QAbstractListModel
        for (let i = 0; i < allAppsModel.rowCount(); i++) {
            let index = allAppsModel.index(i, 0);
            let appName = allAppsModel.data(index, 257); // name
            let appExec = allAppsModel.data(index, 258); // exec
            let appIcon = allAppsModel.data(index, 259); // icon
            let normalizedAppName = appName ? appName.trim().toLowerCase() : "";
            console.log("Checking App:", appName, "(normalized:", normalizedAppName, ")");
            if (normalizedFavoriteKeys.indexOf(normalizedAppName) !== -1) {
                let appData = {
                    "name": appName,
                    "icon": appIcon,
                    "exec": appExec
                };
                launcherApps.append(appData);
            }
        }

        console.log("Favorite apps loaded successfully. Count:", launcherApps.count);
    }


    Component.onCompleted: {
        loadFavoriteApps();
        updateVisibility();
        let allApps = CutieDesktopFileParser.fetchAllEntriesModel()

            console.log("=== Dumping allApps model ===")
                if (allApps && allApps.count !== undefined) {
                            for (let i = 0; i < allApps.count; i++) {
                                            let app = allApps.get(i)
                                                        console.log("App[" + i + "]:", JSON.stringify(app))
                            }
                } else {
                            console.log("allApps is not a valid ListModel or has no count property")
                }
                
                        
                
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
