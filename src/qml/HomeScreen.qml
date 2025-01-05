import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Cutie
import Cutie.Wlc

Item {
    id: homeScreen
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "homeScreen"


    
    CutieWlc {
        id: compositor
    }

    // Favorite Apps Grid
    Rectangle {
        opacity: 1.0 - cutieWlc.blur
        visible: favoriteAppsVisibility
        color: Atmosphere.secondaryAlphaColor
        height: appSwitcher.width / Math.floor(appSwitcher.width / 51) + 16
        radius: 15
        z:1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.leftMargin: 8
        anchors.bottomMargin: 8
        anchors.bottom: parent.bottom

        ListView {
            id: launchAppList
            model: launcherApps
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            orientation: Qt.Horizontal
            clip: true
            spacing: 20

            delegate: Item {
                width: appSwitcher.width / Math.floor(appSwitcher.width / 51)
                height: width
                
                CutieButton {
                    id: appIconButton
                    width: parent.height
                    height: width
                    icon.name: model["Desktop Entry/Icon"]
                    icon.source: "file://" + model["Desktop Entry/Icon"]
                    icon.height: height
                    icon.width: height
                    background: null
                    onClicked:
                        compositor.execApp(model["Desktop Entry/Exec"])
                    onPressAndHold:
                        menu.open()
                    }

                CutieMenu {
                    id: menu
                    opacity: 1.0 - cutieWlc.blur
                    width: appSwitcher.width * 2 / 3
                    CutieMenuItem {
                        text: qsTr("Remove from favorites")
                        onTriggered: {
                            let data = favoriteStore.data;
                            let appKey = "favoriteApp-" + model["Desktop Entry/Name"];
                            if (data.hasOwnProperty(appKey)) {
                                delete data[appKey];
                                console.log("Removing app from favorites:", appKey);
                                favoriteStore.data = data;
                            }
                        }
                    }
                }
            }
        }
    }


}
