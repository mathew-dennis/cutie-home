import QtQuick
import Cutie

Item {
	width: Screen.width
	height: Screen.height

	Image {
		anchors.fill: parent
		source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
		fillMode: Image.PreserveAspectCrop
	}
}
