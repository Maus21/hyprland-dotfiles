import QtQuick
import Quickshell.Io

FocusScope {
    id: root

    signal closeRequested

    property bool showCondition: false
    property string textFontFamily: ""
    property color panelColor: "#12151e"
    property color moduleColor: "#181b24"
    property color borderColor: "#3d4256"
    property color accentColor: "#ff4f7b"
    property color textPrimary: "#d8e7ef"
    property color textSecondary: "#7f8497"
    property string pendingUrl: ""
    property bool pendingIncognito: false

    anchors.fill: parent
    focus: showCondition
    opacity: showCondition ? 1 : 0

    Keys.onEscapePressed: root.closeRequested()

    function reset() {
        searchField.text = "";
        searchField.forceActiveFocus();
    }

    function submit(incognito) {
        const query = searchField.text.trim();
        if (query === "" || browserProcess.running)
            return;
        pendingUrl = "https://www.google.com/search?q=" + encodeURIComponent(query);
        pendingIncognito = incognito;
        browserProcess.running = true;
    }

    onShowConditionChanged: {
        if (showCondition)
            reset();
    }

    Behavior on opacity { NumberAnimation { duration: showCondition ? 180 : 100 } }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: root.panelColor
        border.width: 1
        border.color: root.borderColor
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Row {
            width: parent.width
            height: 24

            Text {
                width: parent.width - searchHint.width
                text: "Google Search"
                color: root.textPrimary
                font.family: root.textFontFamily
                font.pixelSize: 17
                font.weight: Font.DemiBold
            }

            Text {
                id: searchHint
                text: "Alt+Enter for incognito"
                color: root.textSecondary
                font.family: root.textFontFamily
                font.pixelSize: 12
            }
        }

        Rectangle {
            width: parent.width
            height: 48
            radius: 14
            color: root.moduleColor
            border.width: 1
            border.color: searchField.activeFocus ? root.accentColor : root.borderColor

            Text {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: Text.AlignVCenter
                text: "Search Google..."
                visible: searchField.text === ""
                color: root.textSecondary
                font.family: root.textFontFamily
                font.pixelSize: 16
            }

            TextInput {
                id: searchField
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: root.textPrimary
                selectionColor: root.accentColor
                selectedTextColor: root.panelColor
                font.family: root.textFontFamily
                font.pixelSize: 16
                clip: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.submit((event.modifiers & Qt.AltModifier) !== 0);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        root.closeRequested();
                        event.accepted = true;
                    }
                }
            }
        }
    }

    Process {
        id: browserProcess
        command: root.pendingIncognito
            ? ["/usr/bin/chromium", "--profile-directory=Default", "--incognito", root.pendingUrl]
            : ["/usr/bin/chromium", "--profile-directory=Default", root.pendingUrl]
        running: false
        onExited: root.closeRequested()
    }
}
