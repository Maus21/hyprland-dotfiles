source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end
anifetch "$HOME/.local/share/anifetch-cat.gif" -ca " --fg-only"
set -g fish_greeting

fish_add_path "$HOME/.spicetify"

# opencode
fish_add_path "$HOME/.opencode/bin"

set -gx TERMINAL kitty
