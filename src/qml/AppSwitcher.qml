import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Cutie
import Cutie.Wlc

Item {
    id: appSwitcher
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "appSwitcher"

    CutieLabel {
        visible: tabListView.model.length === 0
        anchors.centerIn: parent
        text: "No Running Apps"
        font.bold: true
        font.pixelSize: 16
        opacity: 1.0 - cutieWlc.blur
    }
    
    CutieWlc {
        id: compositor
    }

 
    GridView {
        id: launchAppGrid
        opacity: 1.0 - cutieWlc.blur
        visible: true  // Always visible for testing
        model: launcherApps
        width: parent.width
        cellWidth: width / Math.floor(width / 85)
        cellHeight: cellWidth
        anchors {
            top: parent.top  // Adjusted from parent.bottom
        }
    
        Rectangle {
            anchors.fill: parent
            color: "black"
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
            
            Component.onCompleted: {
                console.log("App name:", model["Desktop Entry/Name"]);
                console.log("App icon source:", "file://" + model["Desktop Entry/Icon"]);
                console.log("App exec command:", model["Desktop Entry/Exec"]);
                console.log("Number of items in launchAppGrid:", launchAppGrid.count);
                logLauncherAppsLength();
            }
        }

        Component.onCompleted: {
            logLauncherAppsLength();
        }
    }

    function logLauncherAppsLength() {
        console.log("Number of items in launcherApps after initial load:", launcherApps.count);
    }

    // old stuff 

}