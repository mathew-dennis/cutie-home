import QtQuick

Item {
    Item {
        x: 0
        y: 0
        height: root.height
        width: 20

        MouseArea { 
            drag.target: parent; drag.axis: Drag.XAxis; drag.minimumX: 0; drag.maximumX: root.width
            anchors.fill: parent

            function getNextState() {
                if (root.state == "appSwitcher")
                    return "notificationScreen";
                else if (root.state == "notificationScreen")
                    return "appSwitcher";
                else return "";
            }

            onReleased: {
                let nextState = getNextState();
                if (parent.x > parent.width) {
                    root.state = nextState;
                    eval(nextState).forceActiveFocus();
                }
                else { 
                    eval(root.state).opacity = 1; 
                    eval(nextState).opacity = 0;
                }
                parent.x = 0;
            }

            onPositionChanged: {
                if (drag.active) {
                    let nextState = getNextState();
                    eval(root.state).opacity = 1 - 2 * parent.x / root.width 
                    eval(nextState).opacity = 2 * parent.x / root.width
                }
            }
        }
    }

    Item {
        x: root.width - 20
        y: 0
        height: root.height
        width: 20

        MouseArea { 
            drag.target: parent; drag.axis: Drag.XAxis; drag.minimumX: -20; drag.maximumX: root.width - 20
            anchors.fill: parent

            function getNextState() {
                if (root.state == "appSwitcher")
                    return "notificationScreen";
                else if (root.state == "notificationScreen")
                    return "appSwitcher";
                else return "";
            }

            onReleased: {
                let nextState = getNextState();
                if (parent.x < root.width - 2 * parent.width) { 
                    root.state = nextState;
                    eval(nextState).forceActiveFocus();
                }
                else { 
                    eval(root.state).opacity = 1; 
                    eval(nextState).opacity = 0;
                }
                parent.x = root.width - 20
            }

            onPositionChanged: {
                if (drag.active) {
                    let nextState = getNextState();
                    eval(root.state).opacity = 2 * parent.x / root.width - 1
                    eval(nextState).opacity = 2 - 2 * parent.x / root.width
                }
            }
        }
    }
}