import QtQuick
import Cutie
import Cutie.Store
import Cutie.Desktopfileparser

Item {
    id: dock

    width: parent ? parent.width : Screen.width
    opacity: bigScreen?1.0: 1.0 -  cutieWlc.blur
    color: Atmosphere.secondaryAlphaColor
    height: 88
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    property var launcherApps: null
    readonly property bool split: true
    readonly property bool merged: false
    property real menuWidth: width * 2 / 3

    property bool interfaceMode: 
        homeConfigStore.data && "InterfaceMode" in homeConfigStore.data 
        ? homeConfigStore.data["InterfaceMode"] 
        : merged

    readonly property real dockScale: {
        if (!homeConfigStore.data)
            return 1.0

        const v = homeConfigStore.data.dockScale
        const raw = (v !== undefined && v > 0) ? v : 1.0

        return Math.round(raw * 10) / 10
    }
    
    property bool panelMode: 
        homeConfigStore.data && "PanelMode" in homeConfigStore.data  
        ? homeConfigStore.data["PanelMode"]  
        : true

    readonly property bool bigScreen: {
        const screenHeight = parent ? parent.height : Screen.height
        const landscape = dock.width > screenHeight
        if (Screen.pixelDensity > 0)
            return landscape && dock.width / Screen.pixelDensity >= 250
        return landscape && dock.width >= 1280
    }

    Component.onCompleted: {
        let model = CutieDesktopFileParser.createFilterModel()
        model.favoriteKeys = Object.keys(favoriteStore.data || {})
        launcherApps = model    
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"

        onDataChanged: {
            if (launcherApps) {
                launcherApps.favoriteKeys = Object.keys(favoriteStore.data || {})
            }
        }
    }

    CutieStore {
        id: homeConfigStore
        appName: "cutie-home"
        storeName: "homeConfigs"
    }

    MiniLauncher {
        id: miniLauncher
        visible: dock.bigScreen && dock.opacity > 0
        width: height
        height: favourits.height
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
    }

    AppFavourites {
        id: favourits
        anchors.leftMargin: miniLauncher.visible ? miniLauncher.width + 16 : 8
    }
}
