#!/usr/bin/env bash

set -e

# Define the steps of initialization
declare -a steps=(init_git init_pkgs init_nvm init_google_chrome init_google_session_dump
  init_mu4e_deps remap_caps init_emacs init_emacs_gtk_theme init_pass_extension
  init_avidemux init_flacon)

# Set default prompt option
SKIP_PROMPT="no"

# Check command line arguments for non-interactive flag
for arg in "$@"; do
  if [ "$arg" = "--non-interactive" ] || [ "$arg" = "-y" ]; then
    SKIP_PROMPT="yes"
  fi
done

# Function to check whether a package is installed
installed() {
  dpkg-query -W -f='${Status}\n' "${1}" 2> /dev/null | awk '/ok installed/{print 0;exit}{print 1}'
}

# Add apt repositories if already not added
apt_add_repos() {
  local repos=("$@")
  for repo in "${repos[@]}"; do
    if ! grep -hr "^deb.*$repo" /etc/apt/sources.list /etc/apt/sources.list.d/ > /dev/null; then
      sudo apt-add-repository -y "$repo"
      sudo apt-get update
    else
      echo "$repo already exists in source list"
    fi
  done
}

# Add apt packages if already not added
apt_install_pkgs() {
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    if ! (installed "$pkg"); then
      sudo apt-get install --assume-yes "$pkg"
    fi
  done
}

# Function to install necessary packages
init_pkgs() {
  local pkgs=(
    # tmux: terminal multiplexer
    tmux

    # rlwrap: readline feature command line wrapper
    rlwrap

    # silversearcher-ag: very fast grep-like program, alternative to ack-grep
    silversearcher-ag

    # pandoc: general markup converter
    pandoc

    # xclip: command line interface to X selections
    xclip

    # jq: lightweight and flexible command-line JSON processor
    jq

    # fd-find: Simple, fast and user-friendly alternative to find
    fd-find

    # viewnior: simple, fast and elegant image viewer
    viewnior

    # vlc: multimedia player and streamer
    vlc

    # youtube-dl: downloader of videos from YouTube and other sites
    youtube-dl

    # hunspell: spell checker and morphological analyzer (program)
    hunspell

    # w3m: WWW browsable pager with excellent tables/frames support
    w3m

    # mpv: video player based on MPlayer/mplayer2
    mpv

    # cmake: cross-platform, open-source make system
    cmake

    # libtool: Generic library support script
    libtool

    # libtool-bin: Generic library support script (libtool binary)
    libtool-bin

    # curl: command line tool for transferring data with URL syntax
    curl

    # wget: retrieves files from the web
    wget

    # net-tools: NET-3 networking toolkit
    net-tools

    # ditaa: convert ASCII diagrams into proper bitmap graphics
    ditaa

    # indent: C language source code formatting program
    indent

    # smartmontools: control and monitor storage systems using S.M.A.R.T.
    smartmontools

    # htop: interactive processes viewer
    htop

    # command-not-found: Suggest installation of packages in interactive bash sessions
    command-not-found

    # nmap: The Network Mapper
    nmap

    # fonts-noto: metapackage to pull in all Noto fonts
    fonts-noto

    # fonts-arphic-ukai: "AR PL UKai" Chinese Unicode TrueType font collection Kaiti style
    fonts-arphic-ukai

    # sysstat: system performance tools for Linux
    sysstat

    # tree: displays an indented directory tree, in color
    tree

    # synapse: semantic file launcher
    synapse

    # bmon: portable bandwidth monitor and rate estimator
    bmon

    # clangd: Language server that provides IDE-like features to editors
    clangd

    # bear: generate compilation database for Clang tooling
    bear

    # tlp: Optimize laptop battery life
    tlp

    # GitHub CLI, GitHub’s official command line tool
    gh

    # lightweight directory-based password manager
    pass

    # simple configuration storage system - graphical editor
    dconf-editor)
  apt_install_pkgs "${pkgs[@]}"
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
  local pkgs=(
    # meson: high-productivity build system
    meson
    # gir1.2-glib-2.0: Introspection data for GLib, GObject, Gio and GModule
    gir1.2-glib-2.0
    gmime-3.0
    # libxapian-dev: Development files for Xapian search engine library
    libxapian-dev
    # libxapian30: Search engine library
    libxapian30
    # guile-3.0: GNU extension language and Scheme interpreter
    guile-3.0
    # xapian-omega: CGI search interface and indexers using Xapian
    xapian-omega
    # xapian-tools: Basic tools for Xapian search engine library
    xapian-tools)
  apt_install_pkgs "${pkgs[@]}"
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
  # By default, '<Control>period' and '<Control>semicolon' in Ubuntu toggle emoji
  # typing, which can be annoying. So, let's turn it off completely.
  gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]"
}

init_pass_extension() {
  apt_add_repos ppa:deadsnakes/ppa # New Python Versions
  apt_install_pkgs python3.9 python3-setuptools python3-yaml python3-defusedxml python3-secretstorage python-magic python3-cryptography
  wget -qO - https://pkg.pujol.io/debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/pujol.io.gpg > /dev/null
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/pujol.io.gpg] https://pkg.pujol.io/debian/repo all main' | sudo tee /etc/apt/sources.list.d/pkg.pujol.io.list
  sudo apt-get update
  sudo apt-get install pass-extension-import
}

init_avidemux() {
  apt_install_pkgs software-properties-common apt-transport-https
  apt_add_repos ppa:xtradeb/apps
  sudo apt install avidemux* -y
}

init_flacon() {
  apt_add_repos ppa:flacon/ppa
  apt_install_pkgs flacon
}

# The main function that runs all the initialization steps
main() {
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
  echo "-y, --non-interactive   Run script without prompting for confirmation."
  echo "-h, --help              Show help and exit."
  echo
  echo "Commands:"
  echo "init_git           Initialize git by installing it and configuring default branch."
  echo "init_pkgs          Install necessary packages"
  echo "init_nvm           Install Node Version Manager if not already installed."
  echo "init_google_chrome Download and install Google Chrome."
  echo "init_google_session_dump Install Google Session Dump."
  echo "init_mu4e_deps     Install dependencies for mu4e."
  echo "remap_caps         Remap Caps Lock to Control key."
  echo "init_emacs         Install Emacs if not already installed."
  echo "init_emacs_gtk_theme Set Emacs as the GTK theme."
  echo "init_pass_extension Install Pass password manager extension."
  echo "init_avidemux      Install avidemux video editing software."
  echo "init_flacon        Install Flacon Audio File Encoder."
  echo
  echo "To invoke multiple commands, space-separate them."
  echo "Example: $(basename "$0") init_git init_nvm"
}

# Check command line arguments for "--help" or "-h", "--non-interactive" or "-y"
for arg in "$@"; do
  if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
    show_help
    exit 0
  elif [ "$arg" = "--non-interactive" ] || [ "$arg" = "-y" ]; then
    SKIP_PROMPT="yes"
  fi
done

args=("$@")
for i in "${!args[@]}"; do
  if [[ "${args[$i]}" = "--non-interactive" ]] || [[ "${args[$i]}" = "-y" ]]; then
    unset 'args[i]'
  fi
done

main "${args[@]}"
