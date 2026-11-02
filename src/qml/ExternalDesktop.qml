import QtQuick
import Cutie
import Cutie.Wlc

CutieWlc { id: cutieWlc }
Item {
	width: parent ? parent.width : Screen.width
	height: parent ? parent.height : Screen.height

	Image {
		anchors.fill: parent
		source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
		fillMode: Image.PreserveAspectCrop
	}
	FooterDock {   id: footer   }
}
