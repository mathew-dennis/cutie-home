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
    anchors.margins: 8
    z: 1
    
    readonly property real baseCellSize:
        appSwitcher.width / Math.floor(appSwitcher.width / 51)

    readonly property int maxVisibleItems: 5

    readonly property int visibleCount:
        Math.min(launcherApps.rowCount(), maxVisibleItems)

    height: (baseCellSize * root.dockScale) + 16

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        color: Atmosphere.secondaryAlphaColor
        radius: 15
        opacity: 1.0 - cutieWlc.blur
        width: root.panelMode ? parent.width : Math.min(parent.width,
            (baseCellSize * visibleCount) + (launchAppList.spacing * Math.max(visibleCount - 1, 0)))


        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

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

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                CutieButton {
                    width: parent.height
                    height: width
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    icon.width: width
                    icon.height: height

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
