import QtQuick
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Store
import Cutie.Desktopfileparser

Item {
    id: miniLauncher

    readonly property int columns: 6
    readonly property int rows: 5
    property real cellSize: 96
    property real padding: 12
    property bool open: false

    property var allAppsModel: null

    function refresh() {
        allAppsModel = CutieDesktopFileParser.fetchAllEntriesModel()
    }

    Component.onCompleted: refresh()
    onVisibleChanged: if (!visible) open = false

    Item {
        id: menuButton
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: miniLauncher.open ? Atmosphere.accentColor : Atmosphere.secondaryAlphaColor
            radius: 15
            opacity: 1.0 - cutieWlc.blur
        }

        Grid {
            anchors.centerIn: parent
            columns: 3
            spacing: menuButton.width / 10

            Repeater {
                model: 9
                Rectangle {
                    width: menuButton.width / 8
                    height: width
                    radius: width / 2
                    color: Atmosphere.textColor
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: miniLauncher.open = !miniLauncher.open
        }
    }

    Item {
        id: popup
        visible: miniLauncher.open
        width: miniLauncher.columns * miniLauncher.cellSize + 2 * miniLauncher.padding
        height: miniLauncher.rows * miniLauncher.cellSize + 2 * miniLauncher.padding
        anchors.left: parent.left
        anchors.bottom: parent.top
        anchors.bottomMargin: 8

        Rectangle {
            anchors.fill: parent
            color: Atmosphere.secondaryAlphaColor
            radius: 15
            opacity: 1.0 - cutieWlc.blur
        }

        GridView {
            id: miniAppGrid
            anchors.fill: parent
            anchors.margins: miniLauncher.padding
            model: miniLauncher.allAppsModel
            cellWidth: miniLauncher.cellSize
            cellHeight: miniLauncher.cellSize
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                width: miniAppGrid.cellWidth
                height: miniAppGrid.cellHeight

                CutieButton {
                    id: appIconButton
                    anchors.fill: parent
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    icon.width: width / 2
                    icon.height: height / 2
                    background: null

                    onClicked: {
                        cutieWlc.execApp(model.exec, "external")
                        miniLauncher.open = false
                    }
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    width: miniLauncher.cellSize * 3

                    CutieMenuItem {
                        text: qsTr("Add to favorites")
                        onTriggered: {
                            let data = favoriteStore.data
                            data[model.name] = model.name
                            favoriteStore.data = data
                        }
                    }
                }

                CutieLabel {
                    anchors.bottom: appIconButton.bottom
                    anchors.horizontalCenter: appIconButton.horizontalCenter
                    text: model.name
                    font.pixelSize: 12
                    clip: true
                    width: 2 * appIconButton.width / 3
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
