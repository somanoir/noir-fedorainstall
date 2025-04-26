# Install required packages
installPackages() {
  for pkg; do
    sudo dnf install --assumeyes "${pkg}"
  done
}

packages_common_utils=(
  "git"
  "git-lfs"
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
  "lm_sensors"
  "yt-dlp"
  "tela-icon-theme"
  "tealdeer"
  "ark"
  "umu-launcher"
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
  "yazi"
  "ImageMagick"
  "qbittorrent"
  "keepassxc"
  "calibre"
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

install_flatpaks () {
  flatpak install flathub com.github.tchx84.Flatseal
  flatpak install flathub de.haeckerfelix.Shortwave
  flatpak install flathub com.valvesoftware.Steam
  flatpak install flathub io.gitlab.librewolf-community
  flatpak install flathub md.obsidian.Obsidian
  flatpak install flathub com.mattjakeman.ExtensionManager
}

install_misc () {
  # RMPC Music player
  cargo install --git https://github.com/mierak/rmpc --locked

  # Ollama
  curl -fsSL https://ollama.com/install.sh | sh

  # Lain for AwesomeWM
  sudo luarocks install lain
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
sudo -i -u root /bin/bash <<EOF
echo "fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
skip_if_unavailable=True" >> /etc/dnf/dnf.conf
EOF

# Fix laptop lid acting like airplane mode key
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

# Change Hostname
echo "Please enter Hostname for your machine: "
read -r hostname
sudo hostnamectl set-hostname "$hostname"

# Do an initial update
echo ":: Updating the system..."
sudo dnf update -y

# Install required packages
echo ":: Installing required utilities..."
installPackages "${packages_common_utils[@]}"
installPackages "${packages_common_x11[@]}"
installPackages "${packages_common_wayland[@]}"

# Install window managers
echo ":: Installing window managers..."
installPackages "${packages_hyprland[@]}"
installPackages "${packages_niri[@]}"
installPackages "${packages_awesome[@]}"
installPackages "${packages_i3[@]}"

# Install fonts and apps
echo ":: Installing fonts..."
installPackages "${packages_fonts[@]}"
echo ":: Installing applications..."
installPackages "${packages_apps[@]}"

# Switch default user shell to Zsh
echo ":: Switching default user shell to Zsh..."
sudo chsh -s /usr/bin/zsh $USER

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

# Create user folders
mkdir /home/$USER/{Code,Games,Media,Misc,Mounts,My}

# Install flatpaks
echo ":: Installing flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
install_flatpaks

# Setup lm_sensors
echo ":: Setting up lm_sensors..."
sudo sensors-detect

# Enable services
echo ":: Enabling systemctl services..."
sudo systemctl enable bluetooth
sudo systemctl enable podman
sudo systemctl enable ollama

# install Noir Dotfiles
echo ":: Installing Noir Dotfiles..."
install_dotfiles
