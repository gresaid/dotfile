#!/bin/sh

# Function to display checkmarks and crosses
checkmark() {
    printf "\e[32m✔\e[0m $1\n"
}

cross() {
    printf "\e[31m✖\e[0m $1\n"
}

# Add necessary repositories
echo ""
read -p ">>> Давайте добавим необходимые репозитории? (y/n) " choice
echo ""
if [ "$choice" = "y" ]; then
    read -p "Flathub нужен? (y/n) " choice
    if [ "$choice" = "y" ]; then
        (flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1 && checkmark "Flathub added")
    else
        cross " Пропуск Flathub"
    fi
    echo ""
    read -p "RPM Fusion нужен? (y/n) " choice
    if [ "$choice" = "y" ]; then
        (sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm > /dev/null 2>&1 && checkmark "RPM Fusion added")
    else
        cross " Пропуск RPM Fusion"
    fi
else
    cross " Пропуск добавления репозиториев"
fi

# System update
echo ""
read -p ">>> Обновить систему? (y/n) " choice
echo ""
if [ "$choice" = "y" ]; then
    (
        sudo dnf upgrade --refresh --best --allowerasing -y > /dev/null 2>&1 && checkmark "System upgraded"
        flatpak update -y > /dev/null 2>&1 && checkmark "Flatpak updated"
        sudo dnf autoremove -y > /dev/null 2>&1 && checkmark "Unused packages removed"
        sudo dnf clean all > /dev/null 2>&1 && checkmark "DNF cache cleaned"
        flatpak uninstall --unused -y > /dev/null 2>&1 && checkmark "Unused Flatpaks removed"
    )
else
    cross " Пропуск обновления системы"
fi

# Install necessary software
read -p "Установить нужный софт? (y/n): " answer
if [ "$answer" = "y" ]; then
    echo "Установка нужного софта..."
    (
        sudo dnf install -y vim git curl wget htop kitty eza neovim bat fastfetch gnome-tweaks gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel lame\* --exclude=lame-devel > /dev/null 2>&1 && checkmark "Software installed"
        flatpak install --noninteractive -y flathub com.google.Chrome org.telegram.desktop com.transmissionbt.Transmission > /dev/null 2>&1 && checkmark "Flatpak software installed"
        sudo dnf group upgrade --with-optional Multimedia -y > /dev/null 2>&1 && checkmark "Multimedia group upgraded"
    )
else
    cross " Пропуск установки софта"
fi


read -p "Установить конфиги?" answer
if [ "$answer" = "y" ]; then
  # Install Zsh using dnf
  (sudo dnf install -y zsh > /dev/null 2>&1 && checkmark "Zsh installed")

  # Install Oh My Zsh
  (sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1 && checkmark "Oh My Zsh installed")

  # Install Powerlevel10k theme
  (git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" > /dev/null 2>&1 && checkmark "Powerlevel10k installed")

  # Install zsh-autosuggestions plugin
  (git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" > /dev/null 2>&1 && checkmark "zsh-autosuggestions installed")

  # Copy kitty configuration
  (cp -r "kitty" "$HOME/.config/" > /dev/null 2>&1 && checkmark "Kitty config installed")

  # Copy .zshrc file
  (cp -r ".zshrc" "$HOME/" > /dev/null 2>&1 && checkmark ".zshrc installed")

  # Source the new .zshrc file
  (source "$HOME/.zshrc" > /dev/null 2>&1 && checkmark ".zshrc sourced")
else
  cross "Пропуск установки конфигов"
fi
# Clean system
(
    sudo dnf autoremove -y > /dev/null 2>&1 && checkmark "Unused packages removed"
    sudo dnf clean all > /dev/null 2>&1 && checkmark "DNF cache cleaned"
    flatpak uninstall --unused -y > /dev/null 2>&1 && checkmark "Unused Flatpaks removed"
)

checkmark "Система очищена"

checkmark "All good"
