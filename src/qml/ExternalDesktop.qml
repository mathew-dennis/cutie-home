import QtQuick
import Cutie
import Cutie.Wlc


Item {
	width: parent ? parent.width : Screen.width
	height: parent ? parent.height : Screen.height

    CutieWlc {
        id: cutieWlc
    }

	Image {
		anchors.fill: parent
		source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
		fillMode: Image.PreserveAspectCrop
	}
	FooterDock {   id: dock   }
}
