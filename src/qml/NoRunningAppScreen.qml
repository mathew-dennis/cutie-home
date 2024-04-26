Item {
    id: noRunningAppScreen
    
    CutieLabel {
        id: noRunningAppsLabel
        visible: tabListView.model.length === 0
        anchors.fill: parent
        text: "No Running Apps"
        font.bold: true
        font.pixelSize: 16
        opacity: 1.0 - cutieWlc.blur
        anchors {
           top: parent.top
           leftMargin: appSwitcher.width / 3
           topMargin: appSwitcher.height / 2
        }
    }

    GridView {
        id: launchAppGrid
        visible: tabListView.model.length === 0
        opacity: 1.0 - cutieWlc.blur
        model: launcherApps
        width: parent.width 
        cellWidth: width / Math.floor(width / 85)
        cellHeight: cellWidth
        anchors {
            top: parent.bottom
            topMargin: -launchAppGrid.cellHeight - 8
        }

        delegate: Item {
            CutieButton {
                id: appIconButton
                width: launchAppGrid.cellWidth
                height: width
                icon.name: model["Desktop Entry/Icon"]
                icon.source: "file://" + model["Desktop Entry/Icon"]
                icon.height: width / 2
                icon.width: height / 2
                background: null
                onClicked:
                    compositor.execApp(model["Desktop Entry/Exec"]);
            }

            CutieLabel {
                anchors.bottom: appIconButton.bottom
                anchors.horizontalCenter: appIconButton.horizontalCenter
                text: model["Desktop Entry/Name"]
                font.pixelSize: 12
                clip: true
                width: 2 * appIconButton.width / 3
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}