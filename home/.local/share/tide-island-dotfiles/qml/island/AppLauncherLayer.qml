import QtQuick
import Quickshell.Io

FocusScope {
    id: root

    signal closeRequested

    property bool showCondition: false
    property string iconFontFamily: ""
    property string textFontFamily: ""
    property int selectedIndex: 0
    property string pendingDesktopFile: ""
    property color panelColor: "#12151e"
    property color moduleColor: "#181b24"
    property color moduleHover: "#202633"
    property color borderColor: "#3d4256"
    property color accentColor: "#ff4f7b"
    property color textPrimary: "#d8e7ef"
    property color textSecondary: "#7f8497"
    property color selectedTextColor: "#12151e"
    readonly property string scanScript: "import configparser,json,os,sys\n"
        + "dirs=[]\n"
        + "for base in [os.path.expanduser('~/.local/share/applications'),os.path.expanduser('~/.local/share/flatpak/exports/share/applications'),'/var/lib/flatpak/exports/share/applications','/usr/local/share/applications','/usr/share/applications']:\n"
        + "    if os.path.isdir(base): dirs.append(base)\n"
        + "seen=set(); rows=[]\n"
        + "for base in dirs:\n"
        + "    for rootdir,_,files in os.walk(base):\n"
        + "        for name in files:\n"
        + "            if not name.endswith('.desktop'): continue\n"
        + "            path=os.path.join(rootdir,name)\n"
        + "            desktop_id=os.path.basename(path)\n"
        + "            if desktop_id in seen: continue\n"
        + "            seen.add(desktop_id)\n"
        + "            cp=configparser.ConfigParser(interpolation=None,strict=False)\n"
        + "            try: cp.read(path,encoding='utf-8')\n"
        + "            except Exception: continue\n"
        + "            if not cp.has_section('Desktop Entry'): continue\n"
        + "            entry=cp['Desktop Entry']\n"
        + "            if entry.get('Type','Application')!='Application': continue\n"
        + "            if entry.get('NoDisplay','false').lower()=='true': continue\n"
        + "            if entry.get('Hidden','false').lower()=='true': continue\n"
        + "            app_name=entry.get('Name','').strip()\n"
        + "            if not app_name: continue\n"
        + "            comment=entry.get('Comment','').strip()\n"
        + "            icon=entry.get('Icon','').strip()\n"
        + "            search=' '.join([entry.get('GenericName',''),entry.get('Exec',''),entry.get('Keywords',''),entry.get('Categories','')]).strip()\n"
        + "            rows.append({'name':app_name,'comment':comment,'icon':icon,'search':search,'filePath':path})\n"
        + "for row in sorted(rows,key=lambda r:r['name'].lower()):\n"
        + "    print(json.dumps(row,separators=(',',':')),flush=True)\n"

    anchors.fill: parent
    focus: showCondition
    opacity: showCondition ? 1 : 0
    Keys.onEscapePressed: root.closeRequested()
    Keys.onDownPressed: root.moveSelection(1)
    Keys.onUpPressed: root.moveSelection(-1)
    Keys.onReturnPressed: root.launchSelected()
    Keys.onEnterPressed: root.launchSelected()

    ListModel { id: appModel }
    ListModel { id: filteredModel }

    function startScan() {
        appModel.clear();
        filteredModel.clear();
        selectedIndex = 0;
        scanProcess.running = true;
    }

    function refilter() {
        const query = searchField.text.toLowerCase().trim();
        filteredModel.clear();
        for (let i = 0; i < appModel.count; i++) {
            const item = appModel.get(i);
            const haystack = (item.name + " " + item.comment + " " + item.search).toLowerCase();
            if (query === "" || haystack.indexOf(query) !== -1)
                filteredModel.append(item);
        }
        selectedIndex = Math.max(0, Math.min(selectedIndex, filteredModel.count - 1));
    }

    function moveSelection(delta) {
        if (filteredModel.count <= 0)
            return;
        selectedIndex = Math.max(0, Math.min(filteredModel.count - 1, selectedIndex + delta));
        appList.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function launchSelected() {
        if (filteredModel.count <= 0)
            return;
        if (launchProcess.running)
            launchProcess.running = false;
        pendingDesktopFile = filteredModel.get(selectedIndex).filePath;
        launchProcess.running = true;
    }

    onShowConditionChanged: {
        if (showCondition) {
            if (appModel.count === 0)
                startScan();
            searchField.forceActiveFocus();
        }
    }

    Behavior on opacity { NumberAnimation { duration: showCondition ? 180 : 100 } }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: panelColor
        border.width: 1
        border.color: borderColor
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Rectangle {
            width: parent.width
            height: 44
            radius: 14
                color: moduleColor
                border.width: 1
                border.color: searchField.activeFocus ? accentColor : borderColor

            TextInput {
                id: searchField
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                color: textPrimary
                selectionColor: accentColor
                selectedTextColor: "#12151e"
                font.family: textFontFamily
                font.pixelSize: 16
                clip: true
                onTextChanged: root.refilter()
            }
        }

        ListView {
            id: appList
            width: parent.width
            height: parent.height - 56
            model: filteredModel
            clip: true
            spacing: 6

            delegate: Rectangle {
                required property int index
                required property string name
                required property string comment
                width: appList.width
                height: 48
                radius: 12
                color: index === root.selectedIndex ? accentColor : (rowMouse.containsMouse ? moduleHover : "transparent")

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    color: index === root.selectedIndex ? root.selectedTextColor : root.textPrimary
                    font.family: root.textFontFamily
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    width: parent.width * 0.46
                    elide: Text.ElideRight
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: comment
                    color: index === root.selectedIndex ? root.selectedTextColor : root.textSecondary
                    font.family: root.textFontFamily
                    font.pixelSize: 12
                    width: parent.width * 0.42
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: root.selectedIndex = index
                    onClicked: root.launchSelected()
                }
            }
        }

        Text {
            width: parent.width
            visible: appModel.count === 0 || filteredModel.count === 0
            text: appModel.count === 0 ? "Scanning apps..." : "No matches"
            color: root.textSecondary
            font.family: root.textFontFamily
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Process {
        id: scanProcess
        command: ["python3", "-c", root.scanScript]
        running: false
        stdout: SplitParser {
            onRead: data => {
                try {
                    appModel.append(JSON.parse(data));
                    root.refilter();
                } catch (error) {
                }
            }
        }
    }

    Process {
        id: launchProcess
        command: ["sh", "-lc", '"$HOME/.local/bin/tide-launch-desktop" "$1"', "tide-launch", root.pendingDesktopFile]
        running: false
        onExited: root.closeRequested()
    }
}
