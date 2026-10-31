import QtQuick
import Cutie
import Cutie.Store
import Cutie.Wlc
import Cutie.Desktopfileparser

Item {
	id: footer
	width: parent ? parent.width : Screen.width
	height: 88

	  
    property var launcherApps: null
    readonly property bool split: true
    readonly property bool merged: false

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

	  Component.onCompleted: {
        let model = CutieDesktopFileParser.createFilterModel()
        model.favoriteKeys = Object.keys(favoriteStore.data || {})
        launcherApps = model    
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"

        onDataChanged:
            launcherApps.favoriteKeys = Object.keys(favoriteStore.data || {})
    }

    CutieStore {
        id: homeConfigStore
        appName: "cutie-home"
        storeName: "homeConfigs"
    }


	FavouritApps { id: favourits }
}
