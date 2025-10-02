import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Desktopfileparser
import Cutie.Store

Item {
    id: homeScreen
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "homeScreen" 

    CutieWlc { id: compositor }

    // Favorite Apps Container
    Rectangle {
        opacity: 1.0 - cutieWlc.blur
        visible: favoriteAppsVisibility
        color: Atmosphere.secondaryAlphaColor
        height: appSwitcher.width / Math.floor(appSwitcher.width / 51) + 16
        radius: 15
        z: 1
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
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    icon.height: height
                    icon.width: height
                    background: null

                    onClicked: compositor.execApp(model.exec)
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    opacity: 1.0 - cutieWlc.blur
                    width: appSwitcher.width * 2 / 3

                    CutieMenuItem {
                        text: qsTr("Remove from favorites")
                        onTriggered: {
                            let data = favoriteStore.data;
                            let appName = model.name;
                            
                            if (data.hasOwnProperty(appName)) {
                                delete data[appName];
                                console.log("Removed favorite app:", appName);
                                favoriteStore.data = data; 
                            }
                        }
                    }
                }
            }
        }
    }
}
