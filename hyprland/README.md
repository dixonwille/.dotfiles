## Apps

- hyprland
- hyprpaper
- hypridle
- hyprlock
- hyprpolkitagent
- xdg-desktop-portal-hyprland
- waybar
- ghostty
    - uninstall kitty
- zen-browser
- rofi-wayland
- qt5-wayland
- qt6-wayland
- swaync

## Setting dark theme

- `gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"`

## Setting up 1Password

- `sudo ln -sf /opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign`

## Start apps

- `systemctl --user enable gnome-keyring-daemon`
- `systemctl --user enable hyperpolkitagent`
- `systemctl --user enable waybar`
- `systemctl --user enable swaync`
- `systemctl --user enable hyprpaper`
- `systemctl --user enable hypridle`
