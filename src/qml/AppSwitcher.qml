import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Cutie

Item {
    id: appSwitcher
    anchors.fill: parent
    opacity: 0
    enabled: root.state == "appSwitcher"
}
