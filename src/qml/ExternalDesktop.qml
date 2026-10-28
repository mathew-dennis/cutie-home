import QtQuick
import Cutie

Item {
	width: parent ? parent.width : Screen.width
	height: parent ? parent.height : Screen.height

	Image {
		anchors.fill: parent
		source: "file:/" + Atmosphere.path + "/wallpaper.jpg"
		fillMode: Image.PreserveAspectCrop
	}
}
