import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Store

Item {
    id: favourits

    property real menuWidth: 300

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 8
    z: 1
    
    readonly property real baseCellSize:
        Screen.width / Math.floor(Screen.width / 51)

    readonly property int maxVisibleItems: 5

    readonly property int visibleCount:
        launcherApps ? Math.min(launcherApps.rowCount(), maxVisibleItems) : 0

    height: (baseCellSize * dock.dockScale) + 16

    Behavior on height {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        radius: 15
        width: dock.panelMode ? parent.width : Math.min(parent.width,
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
                width: baseCellSize * dock.dockScale
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

                    onClicked: cutieWlc.execApp(model.exec,"current")
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    width: Math.min(favourits.width * 2 / 3,
                                baseCellSize * 6)

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
