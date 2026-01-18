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
    state: "appSwitcher"
    visible: true
    width: Screen.width
    height: Screen.height

    states: [
        State{
            name: "appSwitcher"
            PropertyChanges { target: appSwitcher; opacity: 1 }
            PropertyChanges { target: homeScreen; opacity: 0 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
            PropertyChanges { target: footer; opacity: 0 }
        },
        State {
            name: "homeScreen"
            PropertyChanges { target: appSwitcher; opacity: 0 }
            PropertyChanges { target: homeScreen; opacity: 1 }
            PropertyChanges { target: notificationScreen; opacity: 0 }
            PropertyChanges { target: footer; opacity: 1 }
        },
        State {
            name: "notificationScreen"
            PropertyChanges { target: appSwitcher; opacity: 0 }
            PropertyChanges { target: homeScreen; opacity: 0 }
            PropertyChanges { target: notificationScreen; opacity: 1 }
            PropertyChanges { target: footer; opacity: 0 }

        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { target: notificationScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: homeScreen; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: appSwitcher; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }
            NumberAnimation { target: footer; properties: "opacity"; duration: 300; easing.type: Easing.InOutQuad; }

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
        console.log("home - Loading Favorite store data using DesktopFileParser...");
        if (!favoriteStore.data) {
            console.log("home - Favorite store data is not yet available.");
            return;
        }
        launcherApps.clear();
        let favoriteKeys = Object.keys(favoriteStore.data);
        let allAppsModel = CutieDesktopFileParser.fetchAllEntriesModel();
        if (!allAppsModel) {
            console.log("home - Error: DesktopFileParser model is null.");
            return;
        }
        console.log("allAppsModel received count:", allAppsModel.rowCount());
        for (let i = 0; i < allAppsModel.rowCount(); i++) {
            let index = allAppsModel.index(i, 0);
            let appName = allAppsModel.data(index, 257);
            if (favoriteKeys.indexOf(appName) !== -1) {
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
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"

        onDataChanged:
            loadFavoriteApps()  
    }
    
    CutieStore {
        id: homeConfigStore
        appName: "cutie-home"
        storeName: "homeConfigs"
    }

    readonly property bool split: true
    readonly property bool merged: false
    property bool interfaceMode: homeConfigStore.data && "InterfaceMode" in homeConfigStore.data ? homeConfigStore.data["InterfaceMode"] : merged

    readonly property real dockScale: {
        if (!homeConfigStore.data)
        return 1.0

        const v = homeConfigStore.data.dockScale
        const raw = (v !== undefined && v > 0) ? v : 1.0

        return Math.round(raw * 10) / 10
    }
    property bool panelMode: homeConfigStore.data && "PanelMode" in homeConfigStore.data  ? homeConfigStore.data["PanelMode"] : true

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
    Footer { id: footer }

    ListModel { id: notifications }
    ListModel { id: launcherApps }
}
