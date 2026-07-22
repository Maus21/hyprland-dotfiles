import QtQuick
import IslandBackend

Item {
    id: root

    property real radius: 20
    property bool hovered: false
    property bool pressed: false
    property color panelColor: "#12151e"
    property color moduleColor: "#181b24"
    property color moduleHover: "#202633"
    property color borderColor: "#3d4256"
    property color accentColor: "#67c7ea"
    readonly property real innerRadius: Math.max(0, radius - 1)

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.pressed ? Qt.tint(root.moduleColor, Qt.rgba(1, 1, 1, 0.10)) : (root.hovered ? root.moduleHover : root.moduleColor)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.innerRadius
        color: root.pressed ? root.panelColor : (root.hovered ? root.moduleColor : Qt.darker(root.panelColor, 1.06))
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.innerRadius
        color: StyleTokens.transparent
        border.width: 1
        border.color: root.hovered ? root.accentColor : root.borderColor
    }
}
