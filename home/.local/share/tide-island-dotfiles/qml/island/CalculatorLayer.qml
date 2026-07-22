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
    property string resultText: ""
    property string evaluatingExpression: ""
    property bool resultValid: false

    anchors.fill: parent
    focus: showCondition
    opacity: showCondition ? 1 : 0

    Keys.onEscapePressed: root.closeRequested()

    function reset() {
        evaluationTimer.stop();
        if (evaluationProcess.running)
            evaluationProcess.running = false;
        expressionField.text = "";
        resultText = "";
        resultValid = false;
        expressionField.forceActiveFocus();
    }

    function scheduleEvaluation() {
        resultValid = false;
        resultText = "";
        if (evaluationProcess.running)
            evaluationProcess.running = false;
        if (expressionField.text.trim() !== "")
            evaluationTimer.restart();
    }

    function evaluate() {
        const expression = expressionField.text.trim();
        if (expression === "")
            return;
        evaluatingExpression = expression;
        evaluationProcess.running = true;
    }

    function copyResult() {
        if (!resultValid || resultText === "" || copyProcess.running)
            return;
        copyProcess.running = true;
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

        Text {
            width: parent.width
            text: "Calculator"
            color: root.textPrimary
            font.family: root.textFontFamily
            font.pixelSize: 17
            font.weight: Font.DemiBold
        }

        Rectangle {
            width: parent.width
            height: 48
            radius: 14
            color: root.moduleColor
            border.width: 1
            border.color: expressionField.activeFocus ? root.accentColor : root.borderColor

            Text {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: Text.AlignVCenter
                text: "Type an expression..."
                visible: expressionField.text === ""
                color: root.textSecondary
                font.family: root.textFontFamily
                font.pixelSize: 16
            }

            TextInput {
                id: expressionField
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
                onTextChanged: root.scheduleEvaluation()
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.copyResult();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        root.closeRequested();
                        event.accepted = true;
                    }
                }
            }
        }

        Row {
            width: parent.width
            height: 42
            spacing: 12

            Text {
                width: parent.width - copyHint.width - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: root.resultValid ? root.resultText : (expressionField.text.trim() === "" ? "Result" : "Calculating...")
                color: root.resultValid ? root.accentColor : root.textSecondary
                font.family: root.textFontFamily
                font.pixelSize: root.resultValid ? 24 : 15
                font.weight: root.resultValid ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                id: copyHint
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter to copy"
                color: root.textSecondary
                font.family: root.textFontFamily
                font.pixelSize: 12
            }
        }
    }

    Timer {
        id: evaluationTimer
        interval: 140
        repeat: false
        onTriggered: root.evaluate()
    }

    Process {
        id: evaluationProcess
        command: ["/usr/bin/qalc", "-t", "--", root.evaluatingExpression]
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (root.evaluatingExpression !== expressionField.text.trim())
                    return;
                const output = data.trim();
                if (output !== "") {
                    root.resultText = output;
                    root.resultValid = true;
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                if (root.evaluatingExpression !== expressionField.text.trim())
                    return;
                if (!root.resultValid && data.trim() !== "")
                    root.resultText = "Unable to calculate";
            }
        }
    }

    Process {
        id: copyProcess
        command: ["/usr/bin/wl-copy", "--", root.resultText]
        running: false
        onExited: root.closeRequested()
    }
}
