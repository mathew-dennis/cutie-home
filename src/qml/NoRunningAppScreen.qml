    CutieLabel {
        id: noRunningAppsScreen
        visible: tabListView.model.length === 0
        text: "No Running Apps"
        font.bold: true
        font.pixelSize: 16
        opacity: 1.0 - cutieWlc.blur
        anchors {
           top: appSwitcher.top
           leftMargin: appSwitcher.width / 3
           topMargin: appSwitcher.height / 2
        }
    }