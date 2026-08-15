import QtQuick
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    property bool managerAvailable: false
    property bool ethernetConnected: false
    property string ethernetDevice: ""
    property string ethernetConnection: ""
    property bool wifiConnected: false
    property string wifiDevice: ""
    property string wifiConnection: ""

    readonly property bool connected: ethernetConnected || wifiConnected
    readonly property string connectionType: ethernetConnected
        ? "ethernet"
        : (wifiConnected ? "wifi" : "")
    readonly property string statusText: ethernetConnected
        ? (ethernetConnection.length > 0 ? ethernetConnection : "Connected")
        : (wifiConnected
            ? (wifiConnection.length > 0 ? wifiConnection : "Connected")
            : "Disconnected")

    property var snapshotLines: []
    property bool refreshQueued: false

    function splitEscapedFields(line) {
        const fields = [];
        let value = "";
        let escaped = false;

        for (let index = 0; index < line.length; index++) {
            const character = line.charAt(index);
            if (escaped) {
                value += character;
                escaped = false;
            } else if (character === "\\") {
                escaped = true;
            } else if (character === ":") {
                fields.push(value);
                value = "";
            } else {
                value += character;
            }
        }

        if (escaped)
            value += "\\";
        fields.push(value);
        return fields;
    }

    function applySnapshot(lines) {
        let nextEthernetConnected = false;
        let nextEthernetDevice = "";
        let nextEthernetConnection = "";
        let nextWifiConnected = false;
        let nextWifiDevice = "";
        let nextWifiConnection = "";

        for (let index = 0; index < lines.length; index++) {
            const fields = splitEscapedFields(String(lines[index]));
            if (fields.length < 4)
                continue;

            const device = fields[0].trim();
            const type = fields[1].trim().toLowerCase();
            const state = fields[2].trim().toLowerCase();
            const connection = fields.slice(3).join(":").trim();
            const isConnected = state.indexOf("connected") === 0;

            if (!isConnected)
                continue;

            if (type === "ethernet" && !nextEthernetConnected) {
                nextEthernetConnected = true;
                nextEthernetDevice = device;
                nextEthernetConnection = connection === "--" ? "" : connection;
            } else if (type === "wifi" && !nextWifiConnected) {
                nextWifiConnected = true;
                nextWifiDevice = device;
                nextWifiConnection = connection === "--" ? "" : connection;
            }
        }

        ethernetConnected = nextEthernetConnected;
        ethernetDevice = nextEthernetDevice;
        ethernetConnection = nextEthernetConnection;
        wifiConnected = nextWifiConnected;
        wifiDevice = nextWifiDevice;
        wifiConnection = nextWifiConnection;
        managerAvailable = true;
    }

    function refresh() {
        if (snapshotProcess.running) {
            refreshQueued = true;
            return;
        }

        snapshotLines = [];
        snapshotProcess.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: snapshotProcess

        command: [
            "/usr/bin/env",
            "LC_ALL=C",
            "nmcli",
            "-t",
            "--escape",
            "yes",
            "-f",
            "DEVICE,TYPE,STATE,CONNECTION",
            "device",
            "status"
        ]
        running: false

        stdout: SplitParser {
            onRead: data => root.snapshotLines = root.snapshotLines.concat([String(data)])
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.applySnapshot(root.snapshotLines);
            } else {
                root.managerAvailable = false;
                root.ethernetConnected = false;
                root.ethernetDevice = "";
                root.ethernetConnection = "";
                root.wifiConnected = false;
                root.wifiDevice = "";
                root.wifiConnection = "";
            }

            if (root.refreshQueued) {
                root.refreshQueued = false;
                refreshDebounce.restart();
            }
        }
    }

    Process {
        id: monitorProcess

        command: ["/usr/bin/env", "LC_ALL=C", "nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: refreshDebounce.restart()
        }

        onExited: monitorRestartTimer.restart()
    }

    Timer {
        id: refreshDebounce

        interval: 150
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: monitorRestartTimer

        interval: 3000
        repeat: false
        onTriggered: monitorProcess.running = true
    }
}
