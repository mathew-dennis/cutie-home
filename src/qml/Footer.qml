import QtQuick
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Store

Item {
    id: footer

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 8
    anchors.rightMargin: 8
    anchors.bottomMargin: 8
    opacity: 0
    z: 1

    readonly property real baseCellSize:
        appSwitcher.width / Math.floor(appSwitcher.width / 51)

    height: (baseCellSize * root.dockScale) + 16

    Rectangle {
        color: Atmosphere.secondaryAlphaColor
        radius: 15
        anchors.fill: parent

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
                width: baseCellSize * root.dockScale
                height: width

                CutieButton {
                    width: parent.height
                    height: width
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    background: null

                    onClicked: cutieWlc.execApp(model.exec)
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    width: appSwitcher.width * 2 / 3

                    CutieMenuItem {
                        text: qsTr("Remove from favorites")
                        onTriggered: {
                            let data = favoriteStore.data
                            delete data[model.name]
                            favoriteStore.data = data
                        }
                    }
                }
            }
        }
    }
}
