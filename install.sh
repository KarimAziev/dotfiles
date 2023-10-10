#!/usr/bin/env bash

# Define the steps of initialization
declare -a steps=(init_git init_nvm init_google_chrome init_google_session_dump
  init_mu4e_deps remap_caps init_emacs init_emacs_gtk_theme init_pass_extension
  init_pass init_gh init_avidemux init_dconf_editor init_flacon init_silversearch)

# Set default prompt option
SKIP_PROMPT="no"

# Check command line arguments for non-interactive flag
for arg in "$@"; do
  if [ "$arg" = "--non-interactive" ] || [ "$arg" = "-n" ]; then
    SKIP_PROMPT="yes"
  fi
done

# Function to check whether a package is installed
installed() {
  dpkg-query -W -f='${Status}\n' "${1}" 2> /dev/null | awk '/ok installed/{print 0;exit}{print 1}'
}

# Function to initialize package repositories and install necessary packages
apt_init() {
  init_repos
  sudo apt-get update
  install_pkgs
}

# Function to add necessary repositories
init_repos() {
  local repos=(ppa:git-core/ppa ppa:flacon/ppa ppa:xtradeb/apps ppa:deadsnakes/ppa)
  for repo in "${repos[@]}"; do
    sudo apt-add-repository -y "$repo"
  done
}

# Function to install packages
install_pkgs() {
  local pkgs=(tmux rlwrap silversearcher-ag pandoc xclip jq fd-find viewnior vlc
    youtube-dl hunspell w3m mpv cmake libtool libtool-bin curl wget net-tools
    ditaa indent smartmontools htop command-not-found nmap fonts-noto
    fonts-arphic-ukai sysstat tree synapse bmon clangd bear tlp)

  for pkg in "${pkgs[@]}"; do
    if ! (installed "$pkg"); then
      sudo apt-get install --assume-yes "$pkg"
    fi
  done
}

# These functions initialize various tools and utilities as needed
init_git() {
  sudo apt-get install -y git
  git config --global init.defaultBranch main
}

init_emacs() {
  if ! command -v emacs &> /dev/null; then
    bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/build-emacs/main/build-emacs.sh)"
  fi
}

init_nvm() {
  [ -d "${HOME}/.nvm" ] || wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
}

init_google_chrome() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
}

init_google_session_dump() {
  sudo curl -o /usr/bin/chrome-session-dump -L 'https://github.com/lemnos/chrome-session-dump/releases/download/v0.0.2/chrome-session-dump-linux' && sudo chmod 755 /usr/bin/chrome-session-dump
}

init_mu4e_deps() {
  sudo apt install meson gir1.2-glib-2.0
  sudo apt-get install gmime-3.0 libxapian-dev libxapian30 guile-3.0 xapian-omega xapian-tools
}

remap_caps() {
  local filename="/etc/default/keyboard"
  local search
  local replace
  if grep XKBOPTIONS= $filename; then
    search=$(grep XKBOPTIONS= $filename)
    replace=XKBOPTIONS="\"ctrl:nocaps,grp:toggle\""
    sudo sed -i "s/$search/$replace/" $filename
  else
    echo XKBOPTIONS="\"ctrl:nocaps,grp:toggle\"" | sudo tee -a $filename
  fi
  if [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$XDG_SESSION_TYPE" = "xwayland" ]; then
    setxkbmap -option 'ctrl:nocaps,grp:toggle'
  fi
  sudo dpkg-reconfigure keyboard-configuration
}

init_emacs_gtk_theme() {
  gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
}

init_pass_extension() {
  sudo apt install python3.9 python3-setuptools python3-yaml python3-defusedxml python3-secretstorage python-magic python3-cryptography
  wget -qO - https://pkg.pujol.io/debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/pujol.io.gpg > /dev/null
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/pujol.io.gpg] https://pkg.pujol.io/debian/repo all main' | sudo tee /etc/apt/sources.list.d/pkg.pujol.io.list
  sudo apt-get update
  sudo apt-get install pass-extension-import
}

init_pass() {
  sudo apt-get install -y pass
}

init_gh() {
  sudo apt update
  sudo apt install gh
}

init_avidemux() {
  sudo apt install software-properties-common apt-transport-https -y
  sudo add-apt-repository ppa:xtradeb/apps -y
  sudo apt install avidemux* -y
}

init_dconf_editor() {
  sudo apt-get install -y dconf-editor
}

init_flacon() {
  sudo apt-get update && sudo apt-get install -y flacon
}
init_silversearch() {
  sudo apt-get install -y silversearcher-ag
}

# The main function that runs all the initialization steps
main() {
  apt_init
  local steps_to_execute

  # If "--non-interactive" is among the arguments, ignore it when assigning steps
  if [[ "$#" -gt 0 && "$1" != "--non-interactive" ]]; then
    steps_to_execute=("$@")
  else
    steps_to_execute=("${steps[@]}")
  fi

  for step in "${steps_to_execute[@]}"; do
    if [ "$SKIP_PROMPT" = "yes" ]; then
      $step
    else
      read -r -p "Execute $step? [Y/n] " answer
      if [[ $answer == [Yy]* ]] || [[ -z $answer ]]; then
        $step
      else
        echo "Skipping $step"
      fi
    fi
  done
}

show_help() {
  echo "Usage: $(basename "$0") [OPTIONS] [COMMANDS]"
  echo "Initializes various tools and utilities on a new machine."
  echo
  echo "Options:"
  echo "-n, --non-interactive   Run script without prompting for confirmation."
  echo "-h, --help              Show help and exit."
  echo
  echo "Commands:"
  echo "init_git           Initialize git by installing it and configuring default branch."
  echo "init_nvm           Install Node Version Manager if not already installed."
  echo "init_google_chrome Download and install Google Chrome."
  echo "init_google_session_dump Install Google Session Dump."
  echo "init_mu4e_deps     Install dependencies for mu4e."
  echo "remap_caps         Remap Caps Lock to Control key."
  echo "init_emacs         Install Emacs if not already installed."
  echo "init_emacs_gtk_theme Set Emacs as the GTK theme."
  echo "init_pass_extension Install Pass password manager extension."
  echo "init_pass          Install Pass password manager."
  echo "init_gh            Install GitHub CLI."
  echo "init_avidemux      Install avidemux video editing software."
  echo "init_dconf_editor  Install dconf Editor."
  echo "init_flacon        Install Flacon Audio File Encoder."
  echo "init_silversearch  Install the Silver Searcher."
  echo
  echo "To invoke multiple commands, space-separate them."
  echo "Example: $(basename "$0") init_git init_nvm"
}

# Check command line arguments for "--help" or "-h", "--non-interactive" or "-n"
for arg in "$@"; do
  if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
    show_help
    exit 0
  elif [ "$arg" = "--non-interactive" ] || [ "$arg" = "-n" ]; then
    SKIP_PROMPT="yes"
  fi
done

args=("$@")
for i in "${!args[@]}"; do
  if [[ "${args[$i]}" = "--non-interactive" ]] || [[ "${args[$i]}" = "-n" ]]; then
    unset 'args[i]'
  fi
done

main "${args[@]}"
