import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Store
import Cutie.Desktopfileparser

Item {
    id: homeScreen
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "homeScreen"

    property bool editMode: false
    property var homeApps: null

    readonly property real cellSize: 88 * dock.dockScale
    readonly property int columns: Math.max(1, Math.floor(gridArea.width / cellSize))
    readonly property int rows: Math.max(1, Math.floor(gridArea.height / cellSize))
    readonly property real cellW: gridArea.width / columns
    readonly property real cellH: gridArea.height / rows

    onEnabledChanged: if (!enabled) editMode = false

    Component.onCompleted: {
        let model = CutieDesktopFileParser.createFilterModel()
        model.favoriteKeys = Object.keys(homeStore.data || {})
        homeApps = model
    }

    CutieStore {
        id: homeStore
        appName: "cutie-home"
        storeName: "homeItems"

        onDataChanged: {
            if (homeApps) {
                let keys = Object.keys(homeStore.data || {})
                if (JSON.stringify(keys) !== JSON.stringify(homeApps.favoriteKeys))
                    homeApps.favoriteKeys = keys
            }
        }
    }

    function parsePos(posStr) {
        let parts = (posStr || "1x1").split("x")
        let col = Math.min(columns, Math.max(1, parseInt(parts[0]) || 1))
        let row = Math.min(rows, Math.max(1, parseInt(parts[1]) || 1))
        return { col: col, row: row }
    }

    function addApp(name) {
        let data = Object.assign({}, homeStore.data || {})
        if (data[name])
            return
        let occupied = Object.values(data)
        let pos = "1x1"
        outer:
        for (let r = 1; r <= rows; r++) {
            for (let c = 1; c <= columns; c++) {
                let candidate = c + "x" + r
                if (occupied.indexOf(candidate) === -1) {
                    pos = candidate
                    break outer
                }
            }
        }
        data[name] = pos
        homeStore.data = data
    }

    Item {
        id: gridArea
        anchors.fill: parent
        anchors.topMargin: 84
        anchors.bottomMargin: dock.height + 16
        anchors.leftMargin: 16
        anchors.rightMargin: 16

        Repeater {
            model: homeScreen.homeApps

            delegate: Item {
                id: appItem
                width: homeScreen.cellW
                height: homeScreen.cellH

                readonly property var gridPos: homeScreen.parsePos((homeStore.data || {})[model.name])
                readonly property real targetX: (gridPos.col - 1) * homeScreen.cellW
                readonly property real targetY: (gridPos.row - 1) * homeScreen.cellH

                x: targetX
                y: targetY
                z: dragArea.dragging ? 10 : 1
                scale: dragArea.dragging ? 1.1 : 1.0

                Behavior on x { enabled: !dragArea.dragging; NumberAnimation { duration: 150 } }
                Behavior on y { enabled: !dragArea.dragging; NumberAnimation { duration: 150 } }

                Connections {
                    target: homeScreen
                    function onEditModeChanged() {
                        if (!homeScreen.editMode)
                            appItem.rotation = 0
                    }
                }

                SequentialAnimation on rotation {
                    running: homeScreen.editMode
                    loops: Animation.Infinite
                    NumberAnimation { to: 3; duration: 75; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: -3; duration: 75; easing.type: Easing.InOutQuad }
                }

                CutieButton {
                    id: appIcon
                    width: Math.min(parent.width, parent.height) - 20
                    height: width
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    icon.width: width
                    icon.height: height
                    background: null
                    enabled: false
                }

                CutieLabel {
                    anchors.top: appIcon.bottom
                    anchors.topMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 8
                    text: model.name
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    property bool dragging: false
                    drag.target: dragging ? appItem : null
                    drag.axis: Drag.XAndYAxis

                    onClicked: {
                        if (!homeScreen.editMode)
                            cutieWlc.execApp(model.exec, "current")
                    }

                    onPressAndHold: {
                        if (homeScreen.editMode)
                            dragging = true
                        else
                            itemMenu.open()
                    }

                    onReleased: {
                        if (dragging) {
                            dragging = false
                            let col = Math.min(homeScreen.columns, Math.max(1,
                                Math.floor((appItem.x + appItem.width / 2) / homeScreen.cellW) + 1))
                            let row = Math.min(homeScreen.rows, Math.max(1,
                                Math.floor((appItem.y + appItem.height / 2) / homeScreen.cellH) + 1))
                            let newPos = col + "x" + row
                            let data = Object.assign({}, homeStore.data || {})
                            let oldPos = data[model.name]
                            for (let k in data) {
                                if (k !== model.name && data[k] === newPos)
                                    data[k] = oldPos
                            }
                            data[model.name] = newPos
                            homeStore.data = data
                            appItem.x = Qt.binding(function() { return appItem.targetX })
                            appItem.y = Qt.binding(function() { return appItem.targetY })
                        }
                    }

                    onCanceled: {
                        if (dragging) {
                            dragging = false
                            appItem.x = Qt.binding(function() { return appItem.targetX })
                            appItem.y = Qt.binding(function() { return appItem.targetY })
                        }
                    }
                }

                CutieMenu {
                    id: itemMenu
                    width: homeScreen.cellSize * 2.5

                    CutieMenuItem {
                        text: qsTr("Edit")
                        onTriggered: homeScreen.editMode = true
                    }

                    CutieMenuItem {
                        text: qsTr("Remove")
                        onTriggered: {
                            let data = Object.assign({}, homeStore.data || {})
                            delete data[model.name]
                            homeStore.data = data
                        }
                    }
                }
            }
        }
    }

    CutieButton {
        id: closeEditBtn
        visible: homeScreen.editMode
        text: qsTr("Close")
        font.pixelSize: 18
        font.bold: true
        width: 160
        height: 48
        anchors.top: parent.top
        anchors.topMargin: 36
        anchors.horizontalCenter: parent.horizontalCenter
        z: 20
        onClicked: homeScreen.editMode = false
    }
}
