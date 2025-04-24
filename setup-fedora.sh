# Install required packages
_installPackages() {
    toInstall=()
    for pkg; do
        if [[ $(_isInstalled "${pkg}") == 0 ]]; then
            echo "${pkg} is already installed."
            continue
        fi
        toInstall+=("${pkg}")
    done
    if [[ "${toInstall[@]}" == "" ]]; then
        # echo "All dnf packages are already installed.";
        return
    fi
    printf "Package not installed:\n%s\n" "${toInstall[@]}"
    sudo dnf install --assumeyes "${toInstall[@]}"
}

packages_common_utils=(
  "git"
  "wget"
  "unzip"
  "rsync"
  "cmake"
  "meson"
  "cpio"
  "uv"
  "golang"
  "rustup"
  "pkgconf-pkg-config"
  "stow"
  "nwg_look"
  "zsh"
  "fzf"
  "zoxide"
  "lsd"
  "bat"
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
  "lm_sensors"
)

packages_common_x11=(
  "gnome-session-xsession"
  "xorg-x11-xinit-session"
  "xdotool"
  "xclip"
  "xinput"
  "rofi"
  "polybar"
  "dunst"
  "feh"
  "maim"
)

packages_common_wayland=(
  "qt5-qtwayland"
  "qt6-qtwayland"
  "wlogout"
  "copyq"
  "wofi"
  "waybar"
  "mako"
  "swww"
)

packages_hyprland=(
  "hyprland"
  "hyprpicker"
  "pyprland"
  "hyprpolkitagent"
  "hyprshot"
  "xdg-desktop-portal-hyprland"
  "hyprlock"
)

packages_niri=(
  "niri"
  "xwayland-satellite"
  "xdg-desktop-portal-gnome"
)

packages_awesome=(
  "awesome"
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
  "yazi"
  "ImageMagick"
  "qbittorrent"
  "keepassxc"
)

packages_fonts=(
  "maple-fonts"
  "nerd-fonts"
  "mozilla-fira-sans-fonts"
  "fontawesome-6-free-fonts"
)

install_flatpaks () {
  flatpak install flathub de.haeckerfelix.Shortwave
  flatpak install flathub com.valvesoftware.Steam
  flatpak install flathub io.gitlab.librewolf-community
}

install_misc () {
  cargo install --git https://github.com/mierak/rmpc --locked
}

setup_repos () {
  sudo dnf copr enable lihaohong/yazi
  sudo dnf copr enable yalter/niri
  sudo dnf copr enable solopasha/hyprland
  sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
}

install_dotfiles () {
  cd ~
  git clone --depth 1 https://github.com/somanoir/.noir-dotfiles.git
  cd .noir-dotfiles
  stow .

  bat cache --build
  sudo flatpak override --filesystem=xdg-data/themes
}

setup_mpd () {
  mkdir ~/.local/share/mpd
  touch ~/.local/share/mpd/database
  mkdir ~/.local/share/mpd/playlists
  touch ~/.local/share/mpd/state
  touch ~/.local/share/mpd/sticker.sql

  systemctl --user enable --now mpd.service
  mpc update
}

setup_nvidia () {
  sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
  sudo dnf mark user akmod-nvidia
}

setup_multimedia () {
  # Switch to full ffmpeg
  sudo dnf swap ffmpeg-free ffmpeg --allowerasing

  # Install additional codec
  sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

  # Hardware Accelerated Codec
  sudo dnf install intel-media-driver

  # Hardware codecs with NVIDIA
  sudo dnf install libva-nvidia-driver.{i686,x86_64}

  # Play a DVD
  sudo dnf install rpmfusion-free-release-tainted
  sudo dnf install libdvdcss

  # Various firmwares
  sudo dnf install rpmfusion-nonfree-release-tainted
  sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
}


# Setup extra repos
echo ":: Setting up repositories..."
setup_repos

# Tweak DNF config
sudo cat > /etc/dnf/dnf.conf <<EOF
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
EOF

# Change Hostname
echo "Please enter Hostname for your machine: "
read -r hostname
sudo hostnamectl set-hostname "$hostname"

# Do an initial update
echo ":: Updating the system..."
sudo dnf update -y

# Install required packages
echo ":: Installing required utilities..."
_installPackages "${packages_common_utils[@]}"
_installPackages "${packages_common_x11[@]}"
_installPackages "${packages_common_wayland[@]}"

# Install window managers
echo ":: Installing window managers..."
_installPackages "${packages_hyprland[@]}"
_installPackages "${packages_niri[@]}"
_installPackages "${packages_awesome[@]}"

# Install fonts and apps
echo ":: Installing fonts..."
_installPackages "${packages_fonts[@]}"
echo ":: Installing applications..."
_installPackages "${packages_apps[@]}"

# Setup rust
rustup-init

# Install miscellaneous packages
install_misc

# Setup multimedia
echo ":: Setting up multimedia codecs..."
setup_multimedia

# Setup Nvidia drivers
echo ":: Setting up Nvidia drivers..."
setup_nvidia

# Setup mandatory mpd folders and files
echo ":: Setting up MPD..."
setup_mpd

# Install flatpaks
echo ":: Installing flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
install_flatpaks

# Setup lm_sensors
echo ":: Setting up lm_sensors..."
sudo sensors-detect

# install Noir Dotfiles
echo ":: Installing Noir Dotfiles..."
install_dotfiles
