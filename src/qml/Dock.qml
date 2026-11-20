import QtQuick
import Cutie
import Cutie.Wlc
import Cutie.Store
import Cutie.Desktopfileparser

Rectangle {
    id: dock
    radius: 15
    height: favourits.height
    width: (dock.bigScreen && !dock.panelMode)
        ? miniLauncher.width + (favourits.visibleCount > 0 ? favourits.iconsWidth + 24 : 16)
        : (parent ? parent.width : Screen.width)
    color: dock.bigScreen ? Atmosphere.secondaryAlphaColor : "transparent"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: (dock.bigScreen && !dock.panelMode) ? 8 : 0

    property var launcherApps: null
    readonly property bool split: true
    readonly property bool merged: false
    property real menuWidth: width * 2 / 3

    property bool interfaceMode: 
        homeConfigStore.data && "InterfaceMode" in homeConfigStore.data 
        ? homeConfigStore.data["InterfaceMode"] 
        : merged

    readonly property real dockScale: {
        const scaleFactor = dock.bigScreen ? 0.7 : 1.0
        if (!homeConfigStore.data)
        return scaleFactor

        const v = homeConfigStore.data.dockScale
        const raw = (v !== undefined && v > 0) ? v : 1.0

        return Math.round(raw * scaleFactor * 10) / 10
    }
    
    property bool panelMode: 
        homeConfigStore.data && "PanelMode" in homeConfigStore.data  
        ? homeConfigStore.data["PanelMode"]  
        : true

    readonly property bool bigScreen: {
        const screenWidth = parent ? parent.width : Screen.width
        const screenHeight = parent ? parent.height : Screen.height
        const landscape = screenWidth > screenHeight
        if (Screen.pixelDensity > 0)
            return landscape && screenWidth / Screen.pixelDensity >= 250
        return landscape && screenWidth >= 1280
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

    AppMiniLauncher {
        id: miniLauncher
        visible: dock.bigScreen && dock.opacity > 0
        width: height
        height: favourits.height - 16
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
    }

    AppFavourites {
        id: favourits
        anchors.leftMargin: miniLauncher.visible ? miniLauncher.width + 16 : 8
        anchors.rightMargin: dockClock.visible ? dockClock.width + 24 : 8
    }

    Column {
        id: dockClock
        visible: dock.bigScreen && dock.panelMode
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        property date currentDate: new Date()

        Timer {
            interval: 1000
            running: dockClock.visible
            repeat: true
            triggeredOnStart: true
            onTriggered: dockClock.currentDate = new Date()
        }

        CutieLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(dockClock.currentDate, "h:mm AP")
            font.pixelSize: Math.max(10, Math.round(13 * dock.dockScale))
        }

        CutieLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(dockClock.currentDate, "MM/dd/yyyy")
            font.pixelSize: Math.max(10, Math.round(13 * dock.dockScale))
        }
    }
}