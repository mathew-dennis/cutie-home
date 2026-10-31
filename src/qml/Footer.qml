import QtQuick
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Store

Item {
    id: footer

    property var launcherApps
    property var favoriteStoreObject
    property var wlcController
    property real dockScale: 1.0
    property bool panelMode: true
    property real layoutWidth: parent ? parent.width : Screen.width

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 8
    z: 1
    
    readonly property real baseCellSize:
        layoutWidth / Math.max(1, Math.floor(layoutWidth / 51))

    readonly property int maxVisibleItems: 5

    readonly property int visibleCount:
        launcherApps ? Math.min(launcherApps.rowCount(), maxVisibleItems) : 0

    height: (baseCellSize * dockScale) + 16

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        color: Atmosphere.secondaryAlphaColor
        radius: 15
        opacity: 1.0 - wlcController.blur
        width: panelMode ? parent.width : Math.min(parent.width,
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
            width: baseCellSize * dockScale
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

                    onClicked: wlcController.execApp(model.exec)
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    width: layoutWidth * 2 / 3

                    CutieMenuItem {
                        text: qsTr("Remove from favorites")
                        onTriggered: {
                            let data = favoriteStoreObject.data
                            delete data[model.name]
                            favoriteStoreObject.data = data
                        }
                    }
                }
            }
        }
    }
}
