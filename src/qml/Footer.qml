import QtQuick
import QtQuick.Controls
import Cutie
import Cutie.Wlc

Item {
    id: footerRoot
    
    // Allow the root to pass the model in
    property alias model: launchAppList.model
    
    // Set a height based on the same logic you used before
    height: width / Math.floor(width / 51) + 16

    Rectangle {
        id: dockBackground
        anchors.fill: parent
        anchors.margins: 8
        color: Atmosphere.secondaryAlphaColor
        radius: 15
        // Reacts to the compositor blur just like your other components
        opacity: 1.0 - cutieWlc.blur

        ListView {
            id: launchAppList
            anchors.fill: parent
            anchors.margins: 8
            orientation: Qt.Horizontal
            spacing: 20
            clip: true
            interactive: contentWidth > width // Only scroll if apps overflow

            delegate: Item {
                // Sizing based on the footer's width
                width: footerRoot.width / Math.floor(footerRoot.width / 51)
                height: width

                CutieButton {
                    id: appIconButton
                    anchors.fill: parent
                    icon.name: model.icon
                    icon.source: "file://" + model.icon
                    icon.height: height
                    icon.width: height
                    background: null

                    onClicked: cutieWlc.execApp(model.exec)
                    onPressAndHold: menu.open()
                }

                CutieMenu {
                    id: menu
                    width: 200 // Fixed width for the menu is usually safer

                    CutieMenuItem {
                        text: qsTr("Remove from favorites")
                        onTriggered: {
                            let data = favoriteStore.data;
                            let appName = model.name;
                            if (data.hasOwnProperty(appName)) {
                                delete data[appName];
                                favoriteStore.data = data; 
                            }
                        }
                    }
                }
            }
        }
    }
}