import QtQuick
import IslandBackend

Item {
    id: root

    readonly property var userConfig: UserConfig

    property bool showCondition: false
    property var device: null
    property real volumeLevel: -1
    property string iconText: ""
    property string iconFontFamily: ""
    property string textFontFamily: ""
    property color moduleColor: "#25283a"
    property color borderColor: "#304878"
    property color accentColor: "#7aa2f7"
    property color textPrimary: "#cdd6f4"
    property color textSecondary: "#8b90a8"
    property color errorColor: "#bf616a"
    property color warningColor: "#ebcb8b"
    property color successColor: "#a3be8c"

    readonly property string deviceName: {
        if (!device) return "Bluetooth device";

        const preferred = String(device.deviceName === undefined || device.deviceName === null ? "" : device.deviceName).trim();
        if (preferred.length > 0) return preferred;

        const alias = String(device.name === undefined || device.name === null ? "" : device.name).trim();
        if (alias.length > 0) return alias;

        const address = String(device.address === undefined || device.address === null ? "" : device.address).trim();
        return address.length > 0 ? address : "Bluetooth device";
    }
    readonly property bool batteryAvailable: !!(device && device.batteryAvailable)
    readonly property real batteryRawValue: batteryAvailable ? Math.max(0, Number(device.battery) || 0) : -1
    readonly property int batteryPercent: batteryAvailable
        ? Math.max(0, Math.min(100, Math.round(batteryRawValue <= 1 ? batteryRawValue * 100 : batteryRawValue)))
        : -1
    readonly property bool volumeAvailable: volumeLevel >= 0
    readonly property int volumePercent: volumeAvailable
        ? Math.max(0, Math.min(100, Math.round(volumeLevel * 100)))
        : -1
    readonly property color batteryColor: {
        if (!batteryAvailable) return root.textSecondary;
        if (batteryPercent <= 10) return root.errorColor;
        if (batteryPercent <= 20) return root.warningColor;
        return root.successColor;
    }

    anchors.fill: parent
    anchors.margins: 20
    opacity: showCondition ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: showCondition ? 260 : 100
            easing.type: Easing.InOutQuad
        }
    }

    Column {
        anchors.fill: parent
        spacing: 16

        Item {
            width: parent.width
            height: 66

            Item {
                id: bluetoothIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 58

                Text {
                    anchors.centerIn: parent
                    text: root.iconText
                    color: root.accentColor
                    font.pixelSize: userConfig.iconFontSize + 16
                    font.family: root.iconFontFamily
                }
            }

            Item {
                id: batteryIcon
                anchors.right: parent.right
                y: infoBlock.y + Math.round((nameLine.height - height) / 2)
                width: 28
                height: 14

                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 2
                    radius: 4
                    color: "transparent"
                    border.color: root.textSecondary
                    border.width: 1

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        radius: 2
                        width: root.batteryAvailable ? (parent.width - 4) * (root.batteryPercent / 100.0) : 0
                        color: root.batteryColor

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 160 }
                        }
                    }
                }

                Rectangle {
                    width: 2
                    height: 6
                    radius: 1
                    color: root.textSecondary
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: infoBlock
                anchors.left: bluetoothIcon.right
                anchors.leftMargin: 12
                anchors.right: batteryIcon.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                height: 44

                Row {
                    id: nameLine
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 22
                    spacing: 8

                    Text {
                        width: Math.max(0, parent.width - batteryText.implicitWidth - parent.spacing)
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.deviceName
                        color: root.textPrimary
                        font.pixelSize: userConfig.bodyFontSize - 1
                        font.family: root.textFontFamily
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        id: batteryText
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.batteryAvailable ? root.batteryPercent + "%" : "--"
                        color: root.batteryAvailable ? root.textPrimary : root.textSecondary
                        font.pixelSize: userConfig.bodyFontSize - 3
                        font.family: root.textFontFamily
                        font.weight: Font.DemiBold
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: "Connected"
                    color: root.successColor
                    font.pixelSize: userConfig.bodyFontSize - 4
                    font.family: root.textFontFamily
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }
        }

        Item {
            width: parent.width
            height: 43

            Text {
                id: volumeLabel
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.baseline: volumeValue.baseline
                text: "vol"
                color: root.textPrimary
                font.pixelSize: 12
                font.family: root.textFontFamily
                font.weight: Font.Medium
            }

            Text {
                id: volumeValue
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: volumeTrack.verticalCenter
                text: root.volumeAvailable ? root.volumePercent : "--"
                color: root.textSecondary
                font.pixelSize: 12
                font.family: root.textFontFamily
                font.weight: Font.Medium
            }

            Rectangle {
                id: volumeTrack
                anchors.left: volumeLabel.right
                anchors.leftMargin: 14
                anchors.right: volumeValue.left
                anchors.rightMargin: 14
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 15
                height: 8
                radius: 4
                color: root.moduleColor

                Rectangle {
                    width: root.volumeAvailable ? parent.width * (root.volumePercent / 100.0) : 0
                    height: parent.height
                    radius: parent.radius
                    color: root.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
