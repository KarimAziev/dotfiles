#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive

# Define the steps of initialization
declare -a steps=(init_git init_pkgs init_nvm init_google_chrome init_google_session_dump
  init_mu4e_deps remap_caps init_emacs init_emacs_gtk_theme init_avidemux init_flacon init_pyenv init_sdkman init_ghcup ensure_export_path)

# Set default prompt option
SKIP_PROMPT="no"

# Check command line arguments for non-interactive flag
for arg in "$@"; do
  if [ "$arg" = "--non-interactive" ] || [ "$arg" = "-y" ]; then
    SKIP_PROMPT="yes"
  fi
done

bootstrap() {
  sudo apt-get update
  sudo apt-get install --assume-yes wget apt-transport-https curl gnupg software-properties-common
}

# Function to check whether a package is installed
installed() {
  if dpkg-query -W -f='${Status}\n' "$1" 2> /dev/null | grep -q "install ok installed"; then
    echo "$1 is already installed."
    return 0
  else
    echo "$1 is not installed."
    return 1
  fi
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
    if ! apt-cache show "$pkg" > /dev/null 2>&1; then
      echo "Package $pkg is not available in the repository, skipping installation."
      continue
    fi
    if ! installed "$pkg"; then
      echo "Installing package $pkg..."
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

    # yt-dlp: downloader of videos from YouTube and other sites
    yt-dlp

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
    dconf-editor

    # multimedia framework to decode, encode, transcode, mux, demux, stream, filter and play
    ffmpeg

    # zip: a compression and file packaging utility
    zip
  )
  apt_install_pkgs "${pkgs[@]}"
}

# These functions initialize various tools and utilities as needed
init_git() {
  sudo apt-get install -y git
  git config --global init.defaultBranch main
}

init_emacs() {
  if [ -z "${CI}" ]; then
    if ! command -v emacs &> /dev/null; then
      bash -c "$(wget -qO- https://raw.githubusercontent.com/KarimAziev/build-emacs/main/build-emacs.sh)"
    fi
  fi

}

ensure_export_path() {
  local BASHRC="$HOME/.bashrc"
  if [[ -f "$BASHRC" ]]; then
    # Temporary file for new content
    local TMP_FILE
    TMP_FILE=$(mktemp)

    # Ensure the temporary file is removed on script exit
    trap 'rm -f "$TMP_FILE"' EXIT

    # Remove existing 'export PATH' and related comment lines, redirecting output to temp file
    grep -v -E '^# Export PATH environment variable$|^export PATH$' "$BASHRC" > "$TMP_FILE"

    # Append a newline for spacing if file doesn't end with one
    tail -c1 "$TMP_FILE" | read -r _ || echo >> "$TMP_FILE"

    # Check if 'export PATH' was found in the original .bashrc file
    if grep -q -E '^export PATH$' "$BASHRC"; then
      # Add the comment and 'export PATH' line at the end of the file
      echo "# Export PATH environment variable" >> "$TMP_FILE"
      echo "export PATH" >> "$TMP_FILE"
    else
      # If 'export PATH' wasn't found, append it
      echo "# Export PATH environment variable - added by script" >> "$TMP_FILE"
      echo "export PATH" >> "$TMP_FILE"
    fi

    # Move temp file to original .bashrc location
    mv "$TMP_FILE" "$BASHRC"
  fi
}

init_nvm() {
  # Preparing the NVM part
  local NVM_LINES="
# NVM (Node.js Version Manager) initialization.
export NVM_DIR=\"\$HOME/.nvm\"
# shellcheck disable=SC1090,SC1091
[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"  # This loads nvm
# shellcheck disable=SC1090,SC1091
[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion"

  # Preparing the npm completion part
  local NPM_COMPLETION_LINES="# Enable npm command completion.
if type npm &> /dev/null && type complete &> /dev/null; then
  NPM_COMPLETION=\"\$(npm completion)\"
  if [ -n \"\$NPM_COMPLETION\" ]; then
    eval \"\$NPM_COMPLETION\"
  fi
fi"

  # Insert NVM initialization if not present
  if ! grep -q 'NVM_DIR' "$HOME/.bashrc"; then
    echo "$NVM_LINES" >> "$HOME/.bashrc"
  fi

  # Insert NPM completion if not present
  if ! grep -q 'npm completion' "$HOME/.bashrc"; then
    echo "$NPM_COMPLETION_LINES" >> "$HOME/.bashrc"
  fi

  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
}

init_google_chrome() {
  apt_install_pkgs fonts-liberation libu2f-udev
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
}

init_google_session_dump() {
  sudo curl -o /usr/bin/chrome-session-dump -L 'https://github.com/lemnos/chrome-session-dump/releases/download/v0.0.2/chrome-session-dump-linux' && sudo chmod 755 /usr/bin/chrome-session-dump
}

init_mu4e_deps() {
  local pkgs=(
    # build-essential: Provides compilers (like `gcc`), libraries (like `libc6-dev`), and tools such as `make`
    build-essential
    # meson: High-productivity build system
    meson
    # gir1.2-glib-2.0: Introspection data for GLib, GObject, Gio and GModule
    gir1.2-glib-2.0
    # gmime-3.0: Library used for handling MIME messages
    gmime-3.0
    # libgmime-3.0-dev: The development package for GMime 3.0
    libgmime-3.0-dev
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
  # Skip in CI environments
  if [ -z "${CI}" ]; then
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
    sudo dpkg-reconfigure keyboard-configuration -f noninteractive
  fi

}

init_emacs_gtk_theme() {
  # Check if 'gsettings' command exists
  if ! command -v gsettings > /dev/null; then
    echo "gsettings command not found; skipping theme and emoji hotkey configuration."
    return 0
  fi

  if gsettings list-schemas | grep -q 'org.gnome.desktop.interface'; then
    gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
  else
    echo "Gnome desktop interface schema not found; skipping."
  fi
  # By default, '<Control>period' and '<Control>semicolon' in Ubuntu toggle emoji
  # typing, which can be annoying. So, let's turn it off completely.
  if gsettings list-schemas | grep -q 'org.freedesktop.ibus.panel.emoji'; then
    gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]"
  else
    echo "IBus emoji panel schema not found; skipping."
  fi
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

write_gpg_agent_conf() {
  local gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"
  local pinentry_path="/usr/bin/pinentry-gnome3"

  # Check if pinentry-gnome3 exists and is executable
  if [[ ! -x "$pinentry_path" ]]; then
    echo "The pinentry-gnome3 program is not installed."
    return 1
  fi

  # Check if gpg-agent.conf exists
  if [[ -f "$gpg_agent_conf" ]]; then
    # Write the desired settings to the config file
    cat > "$gpg_agent_conf" << EOF
pinentry-program /usr/bin/pinentry-gnome3
allow-emacs-pinentry
allow-loopback-pinentry
default-cache-ttl 604800
max-cache-ttl 604800
EOF
    echo "gpg-agent.conf has been updated."
  else
    echo "gpg-agent.conf does not exist."
    return 1
  fi

  return 0
}

# SDKMAN installation and setup
init_sdkman() {
  if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
  fi

  # Append SDKMAN init to .bashrc if not already present,
  if ! grep -q 'sdkman-init.sh' ~/.bashrc; then
    {
      echo ''
      echo '# Java Version Manager (SDKMAN) installation and setup'
      echo '# shellcheck disable=SC1090,SC1091'
      # shellcheck disable=SC2016 # avoid SC2016 by using intended single quotes
      echo 'export SDKMAN_DIR="$HOME/.sdkman"'
      echo '# shellcheck disable=SC1090,SC1091'
      # shellcheck disable=SC2016 # avoid SC2016 by using intended single quotes
      echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"'
      echo ''
    } >> ~/.bashrc
  fi
}

# Pyenv Installation
init_pyenv() {
  if [ ! -d "$HOME/.pyenv" ]; then
    echo "Installing Pyenv..."
    curl https://pyenv.run | bash
  fi

  # Append Pyenv init to .bashrc if not already present
  if ! grep -q 'pyenv init' ~/.bashrc; then
    {
      echo ''
      echo '# Python Version Manager (pyenv) installation and setup'
      # shellcheck disable=SC2016 # avoid SC2016 by using intended single quotes
      echo 'export PATH="$HOME/.pyenv/bin:$PATH"'
      # shellcheck disable=SC2016 # avoid SC2016 by using intended single quotes
      echo 'eval "$(pyenv init --path)"'
      # shellcheck disable=SC2016 # avoid SC2016 by using intended single quotes
      echo 'eval "$(pyenv virtualenv-init -)"'
      echo ''
    } >> ~/.bashrc
  fi
}

# Init GHCup the main installer for Haskell
init_ghcup() {
  # Main settings:
  #   * BOOTSTRAP_HASKELL_NONINTERACTIVE - any nonzero value for noninteractive installation
  #   * BOOTSTRAP_HASKELL_NO_UPGRADE - any nonzero value to not trigger the upgrade
  #   * BOOTSTRAP_HASKELL_MINIMAL - any nonzero value to only install ghcup
  #   * GHCUP_USE_XDG_DIRS - any nonzero value to respect The XDG Base Directory Specification
  #   * BOOTSTRAP_HASKELL_VERBOSE - any nonzero value for more verbose installation
  #   * BOOTSTRAP_HASKELL_GHC_VERSION - the ghc version to install
  #   * BOOTSTRAP_HASKELL_CABAL_VERSION - the cabal version to install
  #   * BOOTSTRAP_HASKELL_CABAL_XDG - don't disable the XDG logic (this doesn't force XDG though, because cabal is confusing)
  #   * BOOTSTRAP_HASKELL_INSTALL_NO_STACK - disable installation of stack
  #   * BOOTSTRAP_HASKELL_INSTALL_NO_STACK_HOOK - disable installation stack ghcup hook
  #   * BOOTSTRAP_HASKELL_INSTALL_HLS - whether to install latest hls
  #   * BOOTSTRAP_HASKELL_ADJUST_BASHRC - whether to adjust PATH in bashrc (prepend)
  #   * BOOTSTRAP_HASKELL_ADJUST_CABAL_CONFIG - whether to adjust mingw paths in cabal.config on windows
  #   * BOOTSTRAP_HASKELL_DOWNLOADER - which downloader to use (default: curl)
  #   * GHCUP_BASE_URL - the base url for ghcup binary download (use this to overwrite https://downloads.haskell.org/~ghcup with a mirror)
  #   * GHCUP_MSYS2_ENV - the msys2 environment to use on windows, see https://www.msys2.org/docs/environments/ (defauts to MINGW64, MINGW32 or CLANGARM64, depending on the architecture)

  local pkgs
  # Get the Ubuntu version
  local ubuntu_version
  ubuntu_version=$(lsb_release -r | awk '{print $2}')
  # Convert to an integer for comparison by removing the dot
  local version_as_int
  version_as_int=$(echo "$ubuntu_version" | tr -d '.')

  # Check versions and install packages
  if [ "$version_as_int" -ge 2010 ] && [ "$version_as_int" -lt 2300 ]; then
    echo "Installing dependency for GHCup on Ubuntu >= 20.10 and < 23"
    pkgs=(build-essential curl libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5)
    sudo apt-get update
    apt_install_pkgs "${pkgs[@]}"
  elif [ "$version_as_int" -ge 2300 ]; then
    echo "Installing dependency for GHCup on Ubuntu Version >= 23"
    pkgs=(build-essential curl libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev)
    sudo apt-get update
    apt_install_pkgs "${pkgs[@]}"
  else
    echo "Unsupported version for this script."
  fi
  export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
  export BOOTSTRAP_HASKELL_GHC_VERSION=recommended
  export BOOTSTRAP_HASKELL_CABAL_VERSION=recommended
  export BOOTSTRAP_HASKELL_INSTALL_HLS=1
  export BOOTSTRAP_HASKELL_ADJUST_BASHRC=0

  echo "Installing GHCup, the Haskell toolchain installer..."
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

  ensure_export_path
}

# The main function that runs all the initialization steps
main() {
  bootstrap

  local steps_to_execute

  # If "--non-interactive" is among the arguments, ignore it when assigning steps
  if [[ "$#" -gt 0 && "$1" != "--non-interactive" ]]; then
    steps_to_execute=("$@")
  else
    steps_to_execute=("${steps[@]}")
  fi

  for step in "${steps_to_execute[@]}"; do
    if [ "$SKIP_PROMPT" = "yes" ]; then
      echo "Executing $step"
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
  echo "-y, --non-interactive    Run script without prompting for confirmation."
  echo "-h, --help               Show help and exit."
  echo
  echo "Commands:"
  echo "init_git                 Initialize git by installing it and configuring default branch."
  echo "init_pkgs                Install necessary packages"
  echo "init_nvm                 Install Node Version Manager if not already installed."
  echo "init_pyenv               Install Python Version Manager if not already installed."
  echo "init_sdkman              Install Java Version Manager if not already installed."
  echo "init_google_chrome       Download and install Google Chrome."
  echo "init_google_session_dump Install Google Session Dump."
  echo "init_mu4e_deps           Install dependencies for mu4e."
  echo "remap_caps               Remap Caps Lock to Control key."
  echo "init_emacs               Install Emacs if not already installed."
  echo "init_emacs_gtk_theme     Set Emacs as the GTK theme."
  echo "init_pass_extension      Install Pass password manager extension."
  echo "init_avidemux            Install avidemux video editing software."
  echo "init_flacon              Install Flacon Audio File Encoder."
  echo "init_ghcup               Install GHCup, the Haskell toolchain installer."
  echo "ensure_export_path       Ensure the export PATH commands are moved to the end of .bashrc."
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
