import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Cutie
import Cutie.Wlc
import Cutie.Desktopfileparser
import Cutie.Store

Item {
    id: homeScreen
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "homeScreen" 

    CutieWlc { id: compositor }

    // Favorite Apps Container
    Rectangle {}
}
