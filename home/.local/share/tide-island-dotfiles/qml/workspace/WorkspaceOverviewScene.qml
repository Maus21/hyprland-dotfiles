import QtQuick

Item {
    id: root

    property var screen: null
    property bool showCondition: false
    property bool previewsEnabled: false
    property string textFontFamily: ""
    property string heroFontFamily: ""
    property string wallpaperPath: ""
    property color activeBorderColor: "#ff4f7b"
    property color panelColor: "#1e1e2e"
    property color moduleColor: "#25283a"
    property color moduleHover: "#30344a"
    property color borderColor: "#304878"
    property real windowCornerRadius: 22

    property alias overviewView: overviewView
    property alias overviewDataReady: hyprlandData.ready

    signal closeRequested()

    anchors.fill: parent

    HyprlandData {
        id: hyprlandData
    }

    WorkspaceOverviewLayer {
        id: overviewView

        anchors.centerIn: parent
        screen: root.screen
        hyprlandData: hyprlandData
        showCondition: root.showCondition
        previewsEnabled: root.previewsEnabled
        textFontFamily: root.textFontFamily
        heroFontFamily: root.heroFontFamily
        wallpaperPath: root.wallpaperPath
        activeBorderColor: root.activeBorderColor
        panelColor: root.panelColor
        moduleColor: root.moduleColor
        moduleHover: root.moduleHover
        borderColor: root.borderColor
        windowCornerRadius: root.windowCornerRadius
        onCloseRequested: root.closeRequested()
    }
}
