import QtQuick

FocusScope {
    id: root

    default property alias popupContent: contentLayer.data

    property bool showCondition: false
    property color bridgeColor: "#12151e"
    property color bridgeBorderColor: "#3d4256"
    property real sourceWidth: 154
    property real revealProgress: 0

    focus: showCondition

    Component.onCompleted: revealTimer.start()

    onShowConditionChanged: {
        if (showCondition)
            revealTimer.start();
        else
            revealProgress = 0;
    }

    Timer {
        id: revealTimer
        interval: 0
        onTriggered: root.revealProgress = root.showCondition ? 1 : 0
    }

    Behavior on revealProgress {
        NumberAnimation {
            duration: 380
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        z: 0
        x: parent.width / 2 - width / 2
        y: -15
        width: Math.max(24, Math.min(54, root.sourceWidth * 0.28))
        height: 18
        radius: 9
        color: root.bridgeColor
        border.width: 1
        border.color: root.bridgeBorderColor
        opacity: Math.max(0, Math.min(1, root.revealProgress * 1.8))
        transformOrigin: Item.Bottom
        scale: 0.25 + root.revealProgress * 0.75
    }

    Item {
        id: motionLayer
        z: 1
        anchors.fill: parent
        opacity: root.revealProgress
        y: -8 * (1 - root.revealProgress)

        transform: Scale {
            origin.x: motionLayer.width / 2
            origin.y: 0
            xScale: Math.min(1, root.sourceWidth / Math.max(1, motionLayer.width))
                + (1 - Math.min(1, root.sourceWidth / Math.max(1, motionLayer.width))) * root.revealProgress
            yScale: 0.04 + root.revealProgress * 0.96
        }

        Item {
            id: contentLayer
            anchors.fill: parent
        }
    }
}
