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
    enabled: root.state == "homeScreen" && cutieWlc.blur === 0
    visible: opacity > 0 && cutieWlc.blur < 1.0

    property bool editMode: false
    property var homeApps: null
    property bool iconDragging: false
    readonly property int pageCount: 3
    property int currentPage: 0

    readonly property real iconSize:
        (Screen.width / Math.floor(Screen.width / 51)) * dock.dockScale
    readonly property real cellSize: iconSize + 28
    readonly property int columns: Math.max(1, Math.floor(gridFlick.width / cellSize))
    readonly property int rows: Math.max(1, Math.floor(gridFlick.height / cellSize))
    readonly property real cellW: gridFlick.width / columns
    readonly property real cellH: gridFlick.height / rows

    onEnabledChanged: if (!enabled) editMode = false

    function snapToPage(page) {
        currentPage = Math.max(0, Math.min(pageCount - 1, page))
        snapAnim.to = currentPage * gridFlick.width
        snapAnim.restart()
    }

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
        let col = Math.min(columns * pageCount, Math.max(1, parseInt(parts[0]) || 1))
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
        for (let p = 0; p < pageCount; p++) {
            for (let r = 1; r <= rows; r++) {
                for (let c = 1; c <= columns; c++) {
                    let candidate = (p * columns + c) + "x" + r
                    if (occupied.indexOf(candidate) === -1) {
                        pos = candidate
                        break outer
                    }
                }
            }
        }
        data[name] = pos
        homeStore.data = data
    }

    Item {
        anchors.fill: parent
        opacity: 1.0 - cutieWlc.blur

        Flickable {
            id: gridFlick
            anchors.fill: parent
            anchors.topMargin: 84
            anchors.bottomMargin: dock.height + 32
            anchors.leftMargin: 25
            anchors.rightMargin: 25
            contentWidth: width * homeScreen.pageCount
            contentHeight: height
            interactive: !homeScreen.iconDragging
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 10000
            clip: true

        onWidthChanged: contentX = homeScreen.currentPage * width
        onMovementStarted: snapAnim.stop()
        onMovementEnded: {
            let delta = contentX - homeScreen.currentPage * width
            if (delta > width * 0.2 && homeScreen.currentPage < homeScreen.pageCount - 1)
                homeScreen.snapToPage(homeScreen.currentPage + 1)
            else if (delta < -width * 0.2 && homeScreen.currentPage > 0)
                homeScreen.snapToPage(homeScreen.currentPage - 1)
            else
                homeScreen.snapToPage(Math.round(contentX / width))
        }

        NumberAnimation {
            id: snapAnim
            target: gridFlick
            property: "contentX"
            duration: 220
            easing.type: Easing.OutCubic
        }

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
                    width: homeScreen.iconSize
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

                Timer {
                    id: pageEdgeTimer
                    interval: 450
                    repeat: true
                    running: dragArea.dragging
                    onTriggered: {
                        let relX = appItem.x + appItem.width / 2 - gridFlick.contentX
                        if (relX > gridFlick.width - 36 && homeScreen.currentPage < homeScreen.pageCount - 1) {
                            homeScreen.snapToPage(homeScreen.currentPage + 1)
                            appItem.x += gridFlick.width
                        } else if (relX < 36 && homeScreen.currentPage > 0) {
                            homeScreen.snapToPage(homeScreen.currentPage - 1)
                            appItem.x -= gridFlick.width
                        }
                    }
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
                        if (homeScreen.editMode) {
                            dragging = true
                            homeScreen.iconDragging = true
                        } else {
                            itemMenu.open()
                        }
                    }

                    onReleased: {
                        if (dragging) {
                            dragging = false
                            homeScreen.iconDragging = false
                            let maxCol = homeScreen.columns * homeScreen.pageCount
                            let col = Math.min(maxCol, Math.max(1,
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
                            homeScreen.iconDragging = false
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

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dock.height + 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: homeScreen.pageCount

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: Atmosphere.textColor
                    opacity: index === homeScreen.currentPage ? 0.9 : 0.35

                    MouseArea {
                        anchors.fill: parent
                        onClicked: homeScreen.snapToPage(index)
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
}
