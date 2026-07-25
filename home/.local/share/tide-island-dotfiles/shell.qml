import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import IslandBackend

Scope {
    id: shellRoot

    readonly property bool screenRecordingActive: SystemServices.screenRecordingActive
    property bool focusEnabled: false
    property bool nightLightEnabled: false
    property bool shuttingDown: false
    property bool islandAutoHideRuntimeEnabled: true
    property string tideThemeId: "default"
    property var tidePalette: ({
        panel: "#1e1e2e", module: "#25283a", hover: "#30344a", border: "#304878",
        accent: "#7aa2f7", accentAlt: "#41a6b5", text: "#cdd6f4", muted: "#8b90a8",
        selectedText: "#11131e", error: "#bf616a", warning: "#ebcb8b",
        success: "#a3be8c", info: "#81a1c1"
    })
    property string currentWallpaperPath: ""

    readonly property var userConfig: UserConfig

    NotificationServer {
        id: notificationServer

        keepOnReload: true
        persistenceSupported: false
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: false
        actionIconsSupported: false
        imageSupported: false
        inlineReplySupported: false

        onNotification: function(notification) {
            shellRoot.showNotificationAll(notification.appName, notification.summary, notification.body);
        }
    }

    FileView {
        id: tidePaletteState

        path: StandardPaths.writableLocation(StandardPaths.GenericCacheLocation)
            + "/hypr-theme-switcher/palette.json"
        watchChanges: true
        preload: false
        blockLoading: true
        printErrors: false

        onFileChanged: tidePaletteSyncTimer.restart()
        Component.onCompleted: shellRoot.syncTidePalette()
    }

    Timer {
        id: tidePaletteSyncTimer

        interval: 40
        repeat: false
        onTriggered: shellRoot.syncTidePalette()
    }

    FileView {
        id: currentWallpaperState

        path: StandardPaths.writableLocation(StandardPaths.GenericCacheLocation)
            + "/hypr-theme-switcher/current-wallpaper"
        watchChanges: true
        preload: false
        blockLoading: true
        printErrors: false

        onFileChanged: currentWallpaperSyncTimer.restart()
        Component.onCompleted: shellRoot.syncCurrentWallpaper(true)
    }

    Timer {
        id: currentWallpaperSyncTimer

        interval: 80
        repeat: false
        onTriggered: shellRoot.syncCurrentWallpaper(true)
    }

    function forEachWindow(callback) {
        const windows = panelVariants.instances ? panelVariants.instances : [];
        for (let index = 0; index < windows.length; index++) {
            const window = windows[index];
            if (window)
                callback(window);
        }
    }

    function showNotificationAll(appName, summary, body) {
        if (focusEnabled)
            return;

        shellRoot.forEachWindow((window) => {
            if (window && window.showNotification)
                window.showNotification(appName, summary, body);
        });
    }

    function anyOverviewOpen() {
        if (CompositorBackend.compositor === "niri")
            return false;

        const windows = panelVariants.instances ? panelVariants.instances : [];
        for (let index = 0; index < windows.length; index++) {
            const window = windows[index];
            if (window && window.overviewPhase !== "closed")
                return true;
        }

        return false;
    }

    function prepareOverviewAll() {
        if (CompositorBackend.compositor === "niri")
            return;

        shellRoot.syncCurrentWallpaper(true);
        shellRoot.forEachWindow((window) => window.prepareOverview());
    }

    function cancelPreparedOverviewAll() {
        if (CompositorBackend.compositor === "niri")
            return;

        shellRoot.forEachWindow((window) => window.cancelPreparedOverview());
    }

    function openOverviewAll() {
        if (CompositorBackend.compositor === "niri")
            return;

        shellRoot.syncCurrentWallpaper(true);
        shellRoot.forEachWindow((window) => window.openOverview());
    }

    function closeOverviewAll() {
        if (CompositorBackend.compositor === "niri")
            return;

        shellRoot.forEachWindow((window) => window.closeOverview());
    }

    function toggleOverviewAll() {
        if (CompositorBackend.compositor === "niri")
            return;

        if (shellRoot.anyOverviewOpen())
            shellRoot.closeOverviewAll();
        else
            shellRoot.openOverviewAll();
    }

    function anyIslandShown() {
        const windows = panelVariants.instances ? panelVariants.instances : [];
        for (let index = 0; index < windows.length; index++) {
            const window = windows[index];
            if (window && window.autoHideTargetVisible)
                return true;
        }

        return false;
    }

    function showIslandAll() {
        shellRoot.forEachWindow((window) => {
            if (window && window.showIslandWindow)
                window.showIslandWindow();
        });
    }

    function hideIslandAll() {
        shellRoot.forEachWindow((window) => {
            if (window && window.hideIslandWindow)
                window.hideIslandWindow();
        });
    }

    function toggleIslandAll() {
        if (shellRoot.anyIslandShown())
            shellRoot.hideIslandAll();
        else
            shellRoot.showIslandAll();
    }

    function refreshIslandAutoHideAll() {
        shellRoot.forEachWindow((window) => {
            if (window && window.refreshAutoHideWindow)
                window.refreshAutoHideWindow();
        });
    }

    function refreshOverviewWallpaperCaches(wallpaperPath) {
        const nextWallpaperPath = wallpaperPath !== undefined
            && wallpaperPath !== null
            ? String(wallpaperPath).trim()
            : "";

        if (nextWallpaperPath !== "")
            shellRoot.currentWallpaperPath = nextWallpaperPath;

        shellRoot.forEachWindow((window) => {
            if (window && nextWallpaperPath !== "")
                window.wallpaperPickerActiveWallpaper = nextWallpaperPath;
            if (window && window.prewarmWallpaperCache)
                window.prewarmWallpaperCache();
        });
    }

    function syncCurrentWallpaper(forceRefresh) {
        currentWallpaperState.reload();
        const wallpaperPath = String(currentWallpaperState.text() || "").trim();
        if (wallpaperPath === "")
            return;

        const wallpaperChanged = wallpaperPath !== shellRoot.currentWallpaperPath;
        shellRoot.currentWallpaperPath = wallpaperPath;
        if (wallpaperChanged || forceRefresh === true)
            shellRoot.refreshOverviewWallpaperCaches(wallpaperPath);
    }

    function syncTidePalette() {
        tidePaletteState.reload();
        const rawPalette = String(tidePaletteState.text() || "").trim();
        if (rawPalette === "")
            return;

        try {
            const nextPalette = JSON.parse(rawPalette);
            if (!nextPalette || !nextPalette.panel || !nextPalette.accent || !nextPalette.text)
                return;
            shellRoot.tidePalette = nextPalette;
            if (nextPalette.themeId)
                shellRoot.tideThemeId = String(nextPalette.themeId);
        } catch (error) {
            console.warn("Unable to parse Tide palette:", error);
        }
    }

    function setTideThemeAll(themeId) {
        const theme = String(themeId || "").trim();
        switch (theme) {
        case "race":
        case "yousai":
            shellRoot.tideThemeId = "kanagawa";
            break;
        case "diner":
        case "catppuccin":
            shellRoot.tideThemeId = "crimson";
            break;
        default:
            if (theme !== "")
                shellRoot.tideThemeId = theme;
            break;
        }
        shellRoot.syncTidePalette();
    }

    function forFocusedWindow(callback) {
        const windows = panelVariants.instances ? panelVariants.instances : [];
        let fallbackWindow = null;
        for (let index = 0; index < windows.length; index++) {
            const window = windows[index];
            if (window && !fallbackWindow)
                fallbackWindow = window;
            if (window && window.monitorFocused) {
                callback(window);
                return;
            }
        }

        if (fallbackWindow)
            callback(fallbackWindow);
    }

    IpcHandler {
        target: "overview"

        function toggle() {
            shellRoot.toggleOverviewAll();
        }

        function open() {
            shellRoot.openOverviewAll();
        }

        function close() {
            shellRoot.closeOverviewAll();
        }

        function refreshWallpaperCache() {
            shellRoot.refreshOverviewWallpaperCaches();
        }
    }

    IpcHandler {
        target: "island"

        function show() {
            shellRoot.showIslandAll();
        }

        function open() {
            shellRoot.showIslandAll();
        }

        function reveal() {
            shellRoot.showIslandAll();
        }

        function hide() {
            shellRoot.hideIslandAll();
        }

        function toggle() {
            shellRoot.toggleIslandAll();
        }

        function enableAutoHide() {
            shellRoot.islandAutoHideRuntimeEnabled = true;
            shellRoot.refreshIslandAutoHideAll();
        }

        function disableAutoHide() {
            shellRoot.islandAutoHideRuntimeEnabled = false;
            shellRoot.showIslandAll();
        }
    }

    IpcHandler {
        target: "tide"

        function showClock() {
            shellRoot.forFocusedWindow((window) => window.showClockWindow());
        }

        function showCustom() {
            shellRoot.forFocusedWindow((window) => window.showCustomInfoWindow());
        }

        function showLyrics() {
            shellRoot.forFocusedWindow((window) => window.showLyricsWindow());
        }

        function swipeRight() {
            shellRoot.forFocusedWindow((window) => window.swipeRightWindow());
        }

        function togglePlayer() {
            shellRoot.forFocusedWindow((window) => window.togglePlayerWindow());
        }

        function toggleControlCenter() {
            shellRoot.forFocusedWindow((window) => window.toggleControlCenterWindow());
        }

        function toggleWallpaperPicker() {
            shellRoot.forFocusedWindow((window) => window.toggleWallpaperPickerWindow());
        }

        function toggleLauncher() {
            shellRoot.forFocusedWindow((window) => window.toggleAppLauncherWindow());
        }

        function toggleThemeSwitcher() {
            shellRoot.forFocusedWindow((window) => window.toggleThemeSwitcherWindow());
        }

        function toggleCalculator() {
            shellRoot.forFocusedWindow((window) => window.toggleCalculatorWindow());
        }

        function toggleSearch() {
            shellRoot.forFocusedWindow((window) => window.toggleWebSearchWindow());
        }

        function setTheme(themeId: string) {
            shellRoot.setTideThemeAll(themeId);
        }

    }

    Connections {
        target: SystemServices

        function onNotificationReceived(appName, summary, body) {
            shellRoot.showNotificationAll(appName, summary, body);
        }
    }

    Component.onDestruction: {
        shuttingDown = true;
    }

    Component.onCompleted: {
        SystemServices.ensureUserConfigAvailable();
        SystemServices.requestScreenRecordingSnapshot();
    }

    Variants {
        id: panelVariants

        model: Quickshell.screens

        DynamicIslandWindow {
            required property var modelData

            screen: modelData
            shellRootController: shellRoot
        }
    }
}
