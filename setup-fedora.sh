#!/usr/bin/env bash

# Install required packages
install_packages() {
  for pkg; do
    sudo dnf install --assumeyes "${pkg}"
  done
}

packages_common_utils=(
  "git"
  "git-lfs"
  "lazygit"
  "wget"
  "unzip"
  "rsync"
  "cmake"
  "meson"
  "cpio"
  "uv"
  "golang"
  "rustup"
  "luarocks"
  "podman"
  "pkgconf-pkg-config"
  "stow"
  "nwg-look"
  "zsh"
  "starship"
  "fzf"
  "zoxide"
  "lsd"
  "bat"
  "cava"
  "brightnessctl"
  "playerctl"
  "pavucontrol"
  "alsa-utils"
  "btop"
  "network-manager-applet"
  "python3-pip"
  "python3-gobject"
  "gtk4"
  "fastfetch"
  "bluez"
  "blueman"
  "yt-dlp"
  "tela-icon-theme"
  "tealdeer"
  "ark"
  "ncdu"
  "dkms"
)

packages_common_x11=(
  "gnome-session-xsession"
  "xorg-x11-xinit-session"
  "dex-autostart"
  "xdotool"
  "xclip"
  "cliphist"
  "xinput"
  "rofi"
  "polybar"
  "dunst"
  "feh"
  "maim"
  "picom"
)

packages_common_wayland=(
  "qt5-qtwayland"
  "qt6-qtwayland"
  "wlogout"
  "wl-clipboard"
  "copyq"
  "wofi"
  "waybar"
  "mako"
  "swww"
)

packages_hyprland=(
  "hyprland"
  "hyprland-devel"
  "hyprutils"
  "hyprpicker"
  "hyprpolkitagent"
  "hyprshot"
  "xdg-desktop-portal-hyprland"
  "hyprlock"
  "aquamarine"
  "aquamarine-devel"
  "pyprland"
  "uwsm"
)

packages_niri=(
  "niri"
  "xwayland-satellite"
  "xdg-desktop-portal-gnome"
)

packages_awesome=(
  "awesome"
)

packages_i3=(
  "i3"
)

packages_apps=(
  "ghostty"
  "firefox"
  "neovim"
  "vim"
  "vim-enhanced"
  "codium"
  "codium-marketplace"
  "mpd"
  "mpc"
  "mpv"
  "Thunar"
  "thunar-archive-plugin"
  "thunar-media-tags-plugin"
  "thunar-sendto-clamtk"
  "thunar-vcs-plugin"
  "thunar-volman"
  "dolphin"
  "yazi"
  "ImageMagick"
  "qbittorrent"
  "keepassxc"
  "calibre"
  "foliate"
  "discord"
  "filezilla"
  "gnome-tweaks"
)

packages_fonts=(
  "maple-fonts"
  "nerd-fonts"
  "mozilla-fira-sans-fonts"
  "fontawesome-6-free-fonts"
)

packages_gaming=(
  "steam"
  "lutris"
  "umu-launcher"
)

setup_repos() {
  sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm --assumeyes
  sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
  sudo dnf copr enable lihaohong/yazi --assumeyes
  sudo dnf copr enable yalter/niri --assumeyes
  sudo dnf copr enable solopasha/hyprland --assumeyes
  sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release --assumeyes
}

select_window_managers() {
  IFS=', '
  read -p "→ Choose window managers to install (hyprland, niri, awesome, i3): " -a array
  for choice in "${array[@]}"; do
    case "$choice" in
    hyprland*) install_packages "${packages_hyprland[@]}" ;;
    niri*) install_packages "${packages_niri[@]}" ;;
    awesome*) install_packages "${packages_awesome[@]}" ;;
    i3*) install_packages "${packages_i3[@]}" ;;
    *) echo "→ Invalid window manager: $choice" ;;
    esac
  done
}

install_misc() {
  # RMPC Music player
  cargo install --git https://github.com/mierak/rmpc --locked

  # Wallust color scheme generator
  cargo install wallust

  # Ollama
  curl -fsSL https://ollama.com/install.sh | sh

  # Lain for AwesomeWM
  sudo luarocks install lain
}

setup_multimedia() {
  # Switch to full ffmpeg
  sudo dnf swap ffmpeg-free ffmpeg --allowerasing --assumeyes

  # Install additional codec
  sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --assumeyes

  # Hardware Accelerated Codec
  sudo dnf install intel-media-driver --assumeyes

  # Hardware codecs with NVIDIA
  sudo dnf install libva-nvidia-driver.{i686,x86_64} --assumeyes

  # Play a DVD
  sudo dnf install rpmfusion-free-release-tainted --assumeyes
  sudo dnf install libdvdcss --assumeyes

  # Various firmwares
  sudo dnf install rpmfusion-nonfree-release-tainted --assumeyes
  sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware" --assumeyes
}

setup_nvidia() {
  sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda --assumeyes
  sudo dnf mark user akmod-nvidia
}

install_gaming_tools() {
  read -p "Would you like to install gaming tools? (y/n): " answer
  case "$answer" in
  [Yy] | [Yy][Ee][Ss])
    echo "→ Installing gaming tools..."
    install_packages "${packages_gaming[@]}"
    ;;
  *) echo "→ Skipping installation of gaming tools..." ;;
  esac
}

setup_mpd() {
  mkdir ~/.local/share/mpd
  touch ~/.local/share/mpd/database
  mkdir ~/.local/share/mpd/playlists
  touch ~/.local/share/mpd/state
  touch ~/.local/share/mpd/sticker.sql

  systemctl --user enable --now mpd.service
  mpc update
}

install_flatpaks() {
  flatpak install flathub com.github.tchx84.Flatseal --assumeyes
  flatpak install flathub de.haeckerfelix.Shortwave --assumeyes
  flatpak install flathub io.gitlab.librewolf-community --assumeyes
  flatpak install flathub md.obsidian.Obsidian --assumeyes
  flatpak install flathub com.mattjakeman.ExtensionManager --assumeyes
  flatpak install flathub com.github.vikdevelop.photopea_app --assumeyes
}

install_ags() {
  sudo dnf install --assumeyes sass
  sudo dnf install --assumeyes meson vala valadoc gtk3-devel gtk-layer-shell-devel gobject-introspection-devel wayland-protocols-devel

  git clone --depth 1 https://github.com/aylur/astal.git /tmp/astal
  cd /tmp/astal/lib/astal/io
  meson setup --prefix /usr build
  meson install -C build

  cd /tmp/astal/lib/astal/gtk3
  meson setup --prefix /usr build
  meson install -C build

  cd /tmp/astal/lang/gjs
  meson setup --prefix /usr build
  meson install -C build

  git clone --depth 1 https://github.com/aylur/ags.git /tmp/ags
  cd /tmp/ags
  go install -ldflags "\
      -X 'main.gtk4LayerShell=$(pkg-config --variable=libdir gtk4-layer-shell-0)/libgtk4-layer-shell.so' \
      -X 'main.astalGjs=$(pkg-config --variable=srcdir astal-gjs)'"

  sudo mv ~/go/bin/ags /usr/bin/ags
}

install_dotfiles() {
  read -p "Would you like to install Noir Dotfiles? (y/n): " answer_dotfiles
  case "$answer_dotfiles" in
  [Yy] | [Yy][Ee][Ss])
    echo "→ Installing Noir Dotfiles..."
    read -p "Would you like to install Noir Wallpapers? (y/n): " answer_wallpapers

    cd ~ || exit
    case "$answer_wallpapers" in
    [Yy] | [Yy][Ee][Ss])
      git clone --depth 1 --recurse-submodules https://github.com/somanoir/.noir-dotfiles.git
      ;;
    [Nn] | [Nn][Oo])
      git clone --depth 1 https://github.com/somanoir/.noir-dotfiles.git
      ;;
    esac
    cd .noir-dotfiles || exit
    stow .

    bat cache --build
    sudo flatpak override --filesystem=xdg-data/themes

    return 0
    ;;
  [Nn] | [Nn][Oo])
    echo "→ Skipping installation of Noir Dotfiles..."

    return 0
    ;;
  *)
    return 1
    ;;
  esac
}


clear

cat <<"EOF"
  ______       _                    _____      _
 |  ____|     | |                  / ____|    | |
 | |__ ___  __| | ___  _ __ __ _  | (___   ___| |_ _   _ _ __
 |  __/ _ \/ _` |/ _ \| '__/ _` |  \___ \ / _ \ __| | | | '_ \
 | | |  __/ (_| | (_) | | | (_| |  ____) |  __/ |_| |_| | |_) |
 |_|  \___|\__,_|\___/|_|  \__,_| |_____/ \___|\__|\__,_| .__/
                                                        | |
                                                        |_|
EOF

# Create user folders
mkdir /home/$USER/{Code,Games,Media,Misc,Mounts,My}
mkdir -p /home/$USER/.local/{bin,share/backgrounds,share/icons}

# Setup extra repos
echo "→ Setting up repositories..."
setup_repos

# Tweak DNF config
sudo -i -u root /bin/bash <<EOF
echo "fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
skip_if_unavailable=True" >> /etc/dnf/dnf.conf
EOF

# Fix laptop lid acting like airplane mode key
echo "→ Fixing laptop lid acting like airplane mode key..."
sudo -i -u root /bin/bash <<EOF
mkdir /etc/rc.d
echo "#!/usr/bin/env bash
# Fix laptop lid acting like airplane mode key
setkeycodes d7 240
setkeycodes e058 142" > /etc/rc.d/rc.local
EOF

# Disable password prompt for sudo commands
sudo -i -u root /bin/bash <<EOF
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
EOF

# Do an initial update
echo "→ Updating the system..."
sudo dnf update --assumeyes

# Install required packages
echo "→ Installing required utilities..."
install_packages "${packages_common_utils[@]}"
install_packages "${packages_common_x11[@]}"
install_packages "${packages_common_wayland[@]}"

# Install window managers
select_window_managers

# Install fonts and apps
echo "→ Installing fonts..."
install_packages "${packages_fonts[@]}"
echo "→ Installing applications..."
install_packages "${packages_apps[@]}"

# Switch user and root shell to Zsh
echo "→ Switching user and root shell to Zsh..."
sudo chsh -s /usr/bin/zsh $USER
sudo chsh -s /usr/bin/zsh root

# Setup rust
rustup-init

# Install miscellaneous packages
install_misc

# Setup multimedia
echo "→ Setting up multimedia codecs..."
setup_multimedia

# Setup Nvidia drivers
echo "→ Setting up Nvidia drivers..."
setup_nvidia

# Install gaming tools
install_gaming_tools

# Setup mandatory mpd folders and files
echo "→ Setting up MPD..."
setup_mpd

# Install flatpaks
echo "→ Installing flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --assumeyes
install_flatpaks

# Install AGS (Astal widgets)
echo "→ Installing AGS (Astal widgets)..."
install_ags

# Set right-click dragging to resize windows in GNOME
echo "→ Setting right-click dragging to resize windows in GNOME..."
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# Update tealdeer cache
echo "→ Updating tealdeer cache..."
tldr --update

# Enable services
echo "→ Enabling systemctl services..."
sudo systemctl enable bluetooth
sudo systemctl enable podman
sudo systemctl enable ollama

# Install Noir Dotfiles
until install_dotfiles; do :; done
