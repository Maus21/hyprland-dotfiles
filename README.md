# Hyprland Dotfiles

Private CachyOS/Arch desktop snapshot centered on Hyprland and a customized
Tide Island shell. The installer backs up conflicts, links the tracked files
into the target home, and keeps machine-specific display state out of Git.

## Included

- Hyprland configuration, adaptive workspace layout, helpers, and six coordinated themes
- Customized Tide Island QML, settings template, launcher, and user service
- Kitty, LazyVim, Yazi, Btop, Fish, Fastfetch, and Anifetch with its GIF
- EasyEffects, pavucontrol, PipeWire overrides, GTK styling, fonts, and icons
- Chromium plus a restoration list for the currently installed extensions
- Bluetui and NetworkManager's `nmtui`, including desktop launchers
- The complete wallpaper library through Git LFS

Browser profiles, cookies, passwords, histories, paired Bluetooth device IDs,
caches, host identity, GPU drivers, kernels, gaming applications, Discord,
Spotify, OBS, VSCodium, and inactive Waybar/SwayNC backups are intentionally
excluded.

## Fresh CachyOS install

Install the tools needed to clone a private LFS repository:

```bash
sudo pacman -S --needed git git-lfs base-devel
git lfs install
git clone https://github.com/Maus21/hyprland-dotfiles.git
cd hyprland-dotfiles
git lfs pull
./install.sh --dry-run
./install.sh
```

The normal install may ask for sudo while installing repository/AUR packages.
Existing unmanaged files are moved under
`~/.dotfiles-backups/YYYYMMDD-HHMMSS/`; nothing is silently overwritten.

Start Hyprland once, then generate the local display profile:

```bash
./scripts/configure-displays
```

The generator prefers an external display as primary, assigns workspaces 1–5
to it and 6–10 to a second display, or assigns all ten to the only display.
Its `~/.config/hypr/hardware.lua` output is intentionally ignored by Git.

Useful installer options:

```text
--dry-run        Show package, backup, link, and service operations
--skip-packages  Only restore configuration and assets
--skip-services  Do not enable the Tide Island user service
```

Set `DOTFILES_TARGET_HOME` to exercise the installer against a temporary home.
The installer is idempotent: matching links and service files are skipped, and
locally managed Tide preferences are preserved on later runs.

## Browser restore

Chromium is installed, but personal browser databases are not copied. Sign in
to browser sync if desired, then use `packages/chromium-extensions.tsv` as the
extension checklist. Each ID can be opened as:

```text
https://chromewebstore.google.com/detail/EXTENSION_ID
```

## Maintenance

- Edit linked configs normally; tracked file changes appear in this clone.
- Tide's mutable `userconfig.json` and generated monitor profile stay local.
  Promote intentional Tide changes back into `templates/tide-userconfig.json`
  after replacing absolute home paths with `__HOME__`.
- Run `./scripts/secret-scan` before every push.
- Review `versions.lock` when Hyprland or Tide Island upgrades change their APIs.
- Run `git lfs status` before pushing new wallpapers or binary assets.

The current Fish configuration keeps optional Spicetify and OpenCode paths but
does not install those applications. To switch the login shell after install:

```bash
chsh -s /usr/bin/fish
```
