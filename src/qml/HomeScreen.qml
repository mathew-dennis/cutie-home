import QtQuick
import Cutie
import Cutie.Wlc

Item {
    id: homeScreen
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "homeScreen"
}
