source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end
if set -q KITTY_WINDOW_ID
    kitty @ load-config --override confirm_os_window_close=0
end

anifetch "$HOME/.local/share/anifetch-cat.gif" -ca " --fg-only"

if set -q KITTY_WINDOW_ID
    kitty @ load-config --ignore-overrides
end
set -g fish_greeting

fish_add_path "$HOME/.spicetify"

# opencode
fish_add_path "$HOME/.opencode/bin"

set -gx TERMINAL kitty
