import QtQuick
import IslandBackend

Rectangle {
    id: root

    signal interactionStarted()
    signal valueMoved(real value)
    signal commitRequested()
    signal cancelRequested()

    property string title: ""
    property string iconText: ""
    property string iconFontFamily: ""
    property string textFontFamily: ""
    property real value: 0
    property real knobSize: 24
    property color panelColor: "#12151e"
    property color moduleColor: "#181b24"
    property color moduleHover: "#202633"
    property color trackColor: "#3d4256"
    property color textPrimary: "#d8e7ef"
    property color textSecondary: "#7f8497"
    property color accentColor: "#ff4f7b"
    property color selectedTextColor: "#12151e"
    readonly property bool pressed: sliderArea.pressed

    function clamp01(nextValue) {
        return Math.max(0, Math.min(1, nextValue));
    }

    radius: 24
    color: StyleTokens.clearBlack
    clip: true

    MatteSurface {
        anchors.fill: parent
        radius: root.radius
        hovered: sliderArea.containsMouse
        pressed: sliderArea.pressed
        moduleColor: root.moduleColor
        moduleHover: root.moduleHover
        panelColor: root.trackColor
        borderColor: root.trackColor
        accentColor: root.accentColor
    }

    Item {
        anchors.fill: parent
        anchors.margins: 12

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            text: root.title
            color: root.textPrimary
            font.pixelSize: 13
            font.family: root.textFontFamily
            font.weight: Font.DemiBold
        }

        Rectangle {
            id: sliderTrack
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 22
            radius: 11
            color: root.panelColor
            border.width: 1
            border.color: root.trackColor
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: 18
                height: 18
                radius: 9
                color: StyleTokens.transparent

                Text {
                    anchors.centerIn: parent
                    text: root.iconText
                    color: root.textSecondary
                    font.pixelSize: 13
                    font.family: root.iconFontFamily
                }
            }

            Rectangle {
                width: root.value <= 0.001
                    ? 0
                    : Math.max(34, Math.min(sliderTrack.width, sliderTrack.width * root.value + 1))
                height: parent.height
                radius: parent.radius
                color: root.accentColor
            }

            Rectangle {
                x: Math.max(0, Math.min(parent.width - width, parent.width * root.value - width / 2))
                y: -1
                width: root.knobSize
                height: root.knobSize
                radius: root.knobSize / 2
                border.width: 1
                border.color: "#b8ffffff"
                color: root.textPrimary
            }

            MouseArea {
                id: sliderArea
                anchors.fill: parent
                hoverEnabled: true

                function update(mouseX) {
                    root.valueMoved(root.clamp01(mouseX / width));
                }

                onPressed: function(mouse) {
                    root.interactionStarted();
                    update(mouse.x);
                }
                onPositionChanged: function(mouse) {
                    if (pressed)
                        update(mouse.x);
                }
                onReleased: root.commitRequested()
                onCanceled: root.cancelRequested()
            }
        }
    }
}
