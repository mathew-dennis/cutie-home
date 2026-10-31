import QtQuick
import Cutie
import Cutie.Store
import Cutie.Wlc
import Cutie.Desktopfileparser

Item {
	id: root
	width: parent ? parent.width : Screen.width
	height: 88

	property var launcherApps: null
	readonly property bool split: true
	readonly property bool merged: false
	property bool panelMode: homeConfigStore.data && "PanelMode" in homeConfigStore.data
					 ? homeConfigStore.data["PanelMode"] : true
	readonly property real dockScale: {
		if (!homeConfigStore.data)
			return 1.0
		const value = homeConfigStore.data.dockScale
		const raw = (value !== undefined && value > 0) ? value : 1.0
		return Math.round(raw * 10) / 10
	}

	Component.onCompleted: {
		const model = CutieDesktopFileParser.createFilterModel()
		model.favoriteKeys = Object.keys(favoriteStore.data || {})
		launcherApps = model
	}

	CutieStore {
		id: favoriteStore
		appName: "cutie-launcher"
		storeName: "favoriteItems"
		onDataChanged: {
			if (launcherApps)
				launcherApps.favoriteKeys = Object.keys(favoriteStore.data || {})
		}
	}

	CutieStore {
		id: homeConfigStore
		appName: "cutie-home"
		storeName: "homeConfigs"
	}

	CutieWlc {
		id: cutieWlc
	}

	Item {
		id: appSwitcher
		width: root.width
		height: root.height
		visible: false
	}

	Footer {
		launcherApps: root.launcherApps
		favoriteStoreObject: favoriteStore
		wlcController: cutieWlc
		dockScale: root.dockScale
		panelMode: root.panelMode
		layoutWidth: root.width
	}
}
