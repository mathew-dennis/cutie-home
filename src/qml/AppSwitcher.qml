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
        anchors.centerIn: parent
        text: qsTr("No Running Apps")
        font.bold: true
        font.pixelSize: 18
        opacity: tabListView.model.length === 0
            ? 1.0 - cutieWlc.blur
            : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 2
            color: Atmosphere.accentColor
            radius: 5
            samples: 10
			opacity: 1/3
        }
    }
    
    CutieWlc {
        id: compositor
    }

        Rectangle {
            opacity: 1.0 - cutieWlc.blur
            visible: tabListView.model.length === 0
            color: Atmosphere.secondaryAlphaColor
            radius: 20
            z:1
            height: launchAppList.width + 5
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.bottom: parent.bottom

            ListView {
                id: launchAppList
                model: launcherApps
                anchors.fill: parent
                orientation: Qt.Horizontal
                clip: false
                spacing: -20

                delegate: Item {
                    width: ( appSwitcher.width / Math.floor(width / 85) ) / 2
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
                            compositor.execApp(model["Desktop Entry/Exec"]);
                    }
                }
            }

        }

    // old stuff 
    GridView {
        id: tabListView
        anchors.fill: parent
        anchors.topMargin: 40
        model: toplevelManager.toplevels
        cellWidth: appSwitcher.width / 2
        cellHeight: appSwitcher.height / 2 + 20
        opacity: 1.0 - cutieWlc.blur

        delegate: Item {
            id: appThumb
            width: tabListView.cellWidth
            height: tabListView.cellHeight

            Item {
                id: appBg
                width: appThumb.width - 20
                height: appThumb.height - 20
                x: 10

                NumberAnimation {
                    id: opacityRestore
                    target: appThumb
                    property: "opacity"
                    to: 1
                    duration: 200
                }

                NumberAnimation {
                    id: xRestore
                    target: appBg
                    property: "x"
                    to: 10
                    duration: 200
                }

                Item {
                    id: tileBlurMask
                    x: -appThumb.x-appBg.x-tabListView.x+tabListView.contentX
                    y: -appThumb.y-appBg.y-tabListView.y+tabListView.contentY
                    width: Screen.width
                    height: Screen.height
                    clip: true
                    visible: false
                    Rectangle {
                        width: appBg.width
                        height: appBg.height
                        x: appThumb.x+appBg.x+tabListView.x-tabListView.contentX
                        y: appThumb.y+appBg.y+tabListView.y-tabListView.contentY
                        color: "black"
                        radius: 10
                    }
                }

                OpacityMask {
                    anchors.fill: tileBlurMask
                    source: wallpaperBlur
                    maskSource: tileBlurMask
                }

                Rectangle {
                    color: Atmosphere.secondaryAlphaColor
                    anchors.fill: appBg
                    opacity: 1/3
                    radius: 10
                }

                CutieAppThumbnail {
                    id: thumbImage
                    anchors.fill: appBg
                    anchors.bottomMargin: 25
                    wlc: cutieWlc
                    toplevel: modelData
                }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 25
                    clip: true

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 50
                        radius: 10
                        color: Atmosphere.primaryColor
                    }

                    CutieLabel {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 7
                        text: modelData.title
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: appBg; drag.axis: Drag.XAxis; drag.minimumX: -parent.width; drag.maximumX: parent.width
                    onClicked: {
                        modelData.state = [ForeignToplevelHandleV1.Activated];
                    }

                    onReleased: {
                        if (Math.abs(appBg.x - 10) > parent.width / 3) {
                            modelData.close();
                            appThumb.opacity = 0;
                            closedTm.start();
                        } else { 
                            opacityRestore.start();
                        }
                        xRestore.start();
                    }

                    onPositionChanged: {
                        if (drag.active) {
                            appThumb.opacity = 1 - Math.abs(appBg.x - 10) / parent.width 
                        }
                    }
                }
            }

            Timer {
                id: closedTm
                interval: 1000; running: false; repeat: false
                onTriggered: appThumb.opacity = 1
            }
        }
    } 
}