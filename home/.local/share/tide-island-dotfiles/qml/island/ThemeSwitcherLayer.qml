import QtQuick
import Quickshell.Io

FocusScope {
    id: root

    signal closeRequested
    signal themeApplied(string themeId)

    property bool showCondition: false
    property string textFontFamily: ""
    property int selectedIndex: 0
    property string pendingTheme: ""
    property string currentThemeId: "default"
    property color panelColor: "#1e1e2e"
    property color moduleColor: "#25283a"
    property color moduleHover: "#30344a"
    property color borderColor: "#304878"
    property color accentColor: "#7aa2f7"
    property color accentAltColor: "#41a6b5"
    property color textPrimary: "#cdd6f4"
    property color textSecondary: "#8b90a8"
    property color selectedTextColor: "#11131e"

    anchors.fill: parent
    focus: showCondition
    Keys.onEscapePressed: root.closeRequested()
    Keys.onLeftPressed: root.moveSelection(-1)
    Keys.onRightPressed: root.moveSelection(1)
    Keys.onDownPressed: root.moveSelection(3)
    Keys.onUpPressed: root.moveSelection(-3)
    Keys.onReturnPressed: root.applySelected()
    Keys.onEnterPressed: root.applySelected()

    ListModel {
        id: themeModel
        ListElement { label: "Default"; key: "default"; preview: "#1e1e2e"; swatch: "#7aa2f7" }
        ListElement { label: "Tokyo Night"; key: "tokyo"; preview: "#15161e"; swatch: "#c099ff" }
        ListElement { label: "Nord"; key: "nord"; preview: "#2e3440"; swatch: "#88c0d0" }
        ListElement { label: "Everforest"; key: "everforest"; preview: "#2d353b"; swatch: "#a7c080" }
        ListElement { label: "Kanagawa"; key: "kanagawa"; preview: "#1f1f28"; swatch: "#dca561" }
        ListElement { label: "Crimson Night"; key: "crimson"; preview: "#0b101b"; swatch: "#ff2748" }
    }

    function syncSelection() {
        for (let index = 0; index < themeModel.count; index++) {
            if (themeModel.get(index).key === currentThemeId) {
                selectedIndex = index;
                return;
            }
        }
        selectedIndex = 0;
    }

    function moveSelection(delta) {
        selectedIndex = Math.max(0, Math.min(themeModel.count - 1, selectedIndex + delta));
    }

    function applySelected() {
        pendingTheme = themeModel.get(selectedIndex).key;
        root.themeApplied(pendingTheme);
        if (applyProcess.running)
            applyProcess.running = false;
        applyProcess.running = true;
    }

    onShowConditionChanged: {
        if (showCondition) {
            syncSelection();
            root.forceActiveFocus();
        }
    }

    onCurrentThemeIdChanged: syncSelection()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: panelColor
        border.width: 1
        border.color: borderColor
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            width: parent.width
            height: 22
            text: "Theme"
            color: root.textPrimary
            font.family: root.textFontFamily
            font.pixelSize: 16
            font.weight: Font.DemiBold
            verticalAlignment: Text.AlignVCenter
        }

        Grid {
            width: parent.width
            columns: 3
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: themeModel

                delegate: Rectangle {
                    required property int index
                    required property string label
                    required property string key
                    required property string preview
                    required property string swatch

                    width: (parent.width - 16) / 3
                    height: 106
                    radius: 14
                    readonly property bool applied: key === root.currentThemeId
                    readonly property bool selected: index === root.selectedIndex
                    color: selected || cardMouse.containsMouse ? Qt.lighter(preview, 1.12) : preview
                    border.width: applied || selected ? 2 : 1
                    border.color: applied ? root.accentAltColor : (selected ? root.accentColor : root.borderColor)

                    Column {
                        anchors.centerIn: parent
                        spacing: 9

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 34
                            height: 6
                            radius: 3
                            color: swatch
                        }

                        Text {
                            width: 154
                            text: label.toLowerCase()
                            color: root.textPrimary
                            font.family: root.textFontFamily
                            font.pixelSize: 12
                            font.weight: applied ? Font.DemiBold : Font.Normal
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedIndex = index
                        onClicked: root.applySelected()
                    }
                }
            }
        }
    }

    Process {
        id: applyProcess
        command: ["sh", "-lc", '"$HOME/.local/bin/hypr-theme-switcher" apply "$1"', "tide-theme", root.pendingTheme]
        running: false
        onExited: function(exitCode) {
            if (exitCode === 0)
                root.themeApplied(root.pendingTheme);
        }
    }
}
