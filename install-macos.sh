#!/usr/bin/env bash

set -euo pipefail

# Homebrew is allowed to perform only the operation explicitly requested by
# this script. These must be set before the first brew invocation.
export HOMEBREW_NO_ASK=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_UPGRADE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_AUTOREMOVE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BUNDLE_NO_UPGRADE=1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
BACKUP_STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.local/state/dotfiles/backups/$BACKUP_STAMP"

DRY_RUN=false
# Noninteractive execution is the default. --ask enables one plan prompt;
# --yes remains as an explicit/compatibility spelling of the default.
ASSUME_YES=true
PROFILE=developer
PYTHON_MANAGER=pyenv
PYTHON_VERSION=3.12
NODE_VERSION='lts/*'
NVM_INSTALL_VERSION=0.40.6
BREW_UPDATE=false
FAIL_ON_CONFLICT=false
SKIP_DEFAULTS=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_RUST=false
ONLY_PHASES=

WITH_EMACS=auto
WITH_DROPBOX=auto
WITH_GPG=auto
WITH_MEDIA=auto
WITH_CAD=auto
WITH_AI=auto
WITH_DESKTOP=auto
WITH_XCODE=auto
WITH_ALTTAB=auto

FORCE_EMACS_REINSTALL=false
FORCE_APP_REPLACE=false
FORCE_KARABINER_CONFIG=false
ALTTAB_ARCHIVE="$HOME/Dropbox/AltTab-10.4.0.zip"
ALTTAB_SHA256=09b7908b9d046c63fe1a85cb37f33c88b27ae5123a6b05e30e83f3101f0f6f7f
MPV_APP_ARCHIVE=

BREW_BIN=
# Bash 3.2 treats an expanded empty array as unset under `set -u`. Keep one
# harmless sentinel entry so the EXIT trap is portable to the system Bash.
TEMP_DIRS=("")

if [[ -t 1 && -z ${NO_COLOR-} ]]; then
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[1;33m'
  COLOR_RED=$'\033[31m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_GREEN=
  COLOR_YELLOW=
  COLOR_RED=
  COLOR_RESET=
fi

log_info() {
  printf '%s[INFO]%s %s\n' "$COLOR_GREEN" "$COLOR_RESET" "$*"
}

log_warn() {
  printf '%s[WARNING]%s %s\n' "$COLOR_YELLOW" "$COLOR_RESET" "$*" >&2
}

log_error() {
  printf '%s[ERROR]%s %s\n' "$COLOR_RED" "$COLOR_RESET" "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

print_command() {
  local arg
  printf '  '
  for arg in "$@"; do
    printf '%q ' "$arg"
  done
  printf '\n'
}

run() {
  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run command:"
    print_command "$@"
    return 0
  fi

  log_info "Executing:"
  print_command "$@"
  "$@"
}

run_may_fail() {
  if [[ $DRY_RUN == true ]]; then
    run "$@"
    return 0
  fi

  log_info "Executing (non-fatal):"
  print_command "$@"
  if ! "$@"; then
    log_warn "Non-fatal command failed: $1"
  fi
}

usage() {
  cat <<'EOF'
Install a reproducible macOS developer environment without allowing Homebrew
to auto-update, auto-upgrade, clean up, or autoremove packages.

Usage:
  install-macos.sh [OPTIONS]

Profiles:
  developer   Core developer tools, Docker, Chrome, Karabiner, Node and Python.
              Optional application groups are disabled. This is the default.
  personal    Developer profile plus Emacs, Dropbox, media, CAD, local AI,
              desktop applications and the local AltTab archive. Full Xcode is
              still opt-in.

General options:
  -p, --profile PROFILE          developer or personal (default: developer)
  -n, --dry-run                  Print mutating commands without executing them
  -y, --yes                      Proceed without confirmation (the default)
      --ask                      Require confirmation after printing the plan
  -o, --only PHASES             Comma-separated: defaults,packages,toolchains,
                                dotfiles,apps,verify
      --skip-defaults            Do not apply macOS defaults
      --brew-update              Explicitly run brew update (never the default)
      --fail-on-conflict         Stop instead of backing up conflicting dotfiles
  -h, --help                     Show this help and exit

Runtime options:
      --python-manager MANAGER   pyenv or uv (default: pyenv)
      --python-version VERSION   Python request (default: 3.12)
      --skip-python              Skip Python interpreter setup
      --node-version VERSION     lts/*, node, or an exact version (default: lts/*)
      --skip-node                Skip NVM and Node setup
      --skip-rust                Skip rustup setup

Optional groups (each supports --with-NAME and --skip-NAME):
  emacs, dropbox, gpg, media, cad, ai, desktop, xcode, alttab

Application archive options:
      --alttab-archive PATH      AltTab .zip archive
      --alttab-sha256 SHA256     Expected archive checksum
      --mpv-app-archive PATH     Optional .zip containing mpv.app
      --force-app-replace        Back up and replace a different installed app
      --force-karabiner-config   Replace an existing Karabiner config after backup
      --force-emacs-reinstall    Explicitly uninstall/reinstall Emacs master

Examples:
  ./install-macos.sh --dry-run
  ./install-macos.sh --profile developer --skip-gpg
  ./install-macos.sh --profile personal --skip-emacs --skip-dropbox --skip-gpg
  ./install-macos.sh --with-media --python-manager uv
  ./install-macos.sh --only dotfiles --ask
EOF
}

require_option_value() {
  local option=$1
  local value=${2-}
  [[ -n $value ]] || die "Option $option requires a value."
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -p | --profile)
        require_option_value "$1" "${2-}"
        PROFILE=$2
        shift 2
        ;;
      --profile=*)
        PROFILE=${1#*=}
        shift
        ;;
      -n | --dry-run)
        DRY_RUN=true
        shift
        ;;
      -y | --yes)
        ASSUME_YES=true
        shift
        ;;
      --ask)
        ASSUME_YES=false
        shift
        ;;
      -o | --only)
        require_option_value "$1" "${2-}"
        ONLY_PHASES=$2
        shift 2
        ;;
      --only=*)
        ONLY_PHASES=${1#*=}
        shift
        ;;
      --skip-defaults)
        SKIP_DEFAULTS=true
        shift
        ;;
      --brew-update)
        BREW_UPDATE=true
        shift
        ;;
      --fail-on-conflict)
        FAIL_ON_CONFLICT=true
        shift
        ;;
      --python-manager)
        require_option_value "$1" "${2-}"
        PYTHON_MANAGER=$2
        shift 2
        ;;
      --python-manager=*)
        PYTHON_MANAGER=${1#*=}
        shift
        ;;
      --python-version)
        require_option_value "$1" "${2-}"
        PYTHON_VERSION=$2
        shift 2
        ;;
      --python-version=*)
        PYTHON_VERSION=${1#*=}
        shift
        ;;
      --skip-python)
        SKIP_PYTHON=true
        shift
        ;;
      --node-version)
        require_option_value "$1" "${2-}"
        NODE_VERSION=$2
        shift 2
        ;;
      --node-version=*)
        NODE_VERSION=${1#*=}
        shift
        ;;
      --skip-node)
        SKIP_NODE=true
        shift
        ;;
      --skip-rust)
        SKIP_RUST=true
        shift
        ;;
      --with-emacs) WITH_EMACS=true; shift ;;
      --skip-emacs) WITH_EMACS=false; shift ;;
      --with-dropbox) WITH_DROPBOX=true; shift ;;
      --skip-dropbox) WITH_DROPBOX=false; shift ;;
      --with-gpg) WITH_GPG=true; shift ;;
      --skip-gpg) WITH_GPG=false; shift ;;
      --with-media) WITH_MEDIA=true; shift ;;
      --skip-media) WITH_MEDIA=false; shift ;;
      --with-cad) WITH_CAD=true; shift ;;
      --skip-cad) WITH_CAD=false; shift ;;
      --with-ai) WITH_AI=true; shift ;;
      --skip-ai) WITH_AI=false; shift ;;
      --with-desktop) WITH_DESKTOP=true; shift ;;
      --skip-desktop) WITH_DESKTOP=false; shift ;;
      --with-xcode) WITH_XCODE=true; shift ;;
      --skip-xcode) WITH_XCODE=false; shift ;;
      --with-alttab) WITH_ALTTAB=true; shift ;;
      --skip-alttab) WITH_ALTTAB=false; shift ;;
      --alttab-archive)
        require_option_value "$1" "${2-}"
        ALTTAB_ARCHIVE=$2
        WITH_ALTTAB=true
        shift 2
        ;;
      --alttab-archive=*)
        ALTTAB_ARCHIVE=${1#*=}
        WITH_ALTTAB=true
        shift
        ;;
      --alttab-sha256)
        require_option_value "$1" "${2-}"
        ALTTAB_SHA256=$2
        shift 2
        ;;
      --alttab-sha256=*)
        ALTTAB_SHA256=${1#*=}
        shift
        ;;
      --mpv-app-archive)
        require_option_value "$1" "${2-}"
        MPV_APP_ARCHIVE=$2
        WITH_MEDIA=true
        shift 2
        ;;
      --mpv-app-archive=*)
        MPV_APP_ARCHIVE=${1#*=}
        WITH_MEDIA=true
        shift
        ;;
      --force-app-replace)
        FORCE_APP_REPLACE=true
        shift
        ;;
      --force-karabiner-config)
        FORCE_KARABINER_CONFIG=true
        shift
        ;;
      --force-emacs-reinstall)
        FORCE_EMACS_REINSTALL=true
        WITH_EMACS=true
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done
}

set_profile_defaults() {
  case $PROFILE in
    developer)
      [[ $WITH_EMACS == auto ]] && WITH_EMACS=false
      [[ $WITH_DROPBOX == auto ]] && WITH_DROPBOX=false
      [[ $WITH_GPG == auto ]] && WITH_GPG=true
      [[ $WITH_MEDIA == auto ]] && WITH_MEDIA=false
      [[ $WITH_CAD == auto ]] && WITH_CAD=false
      [[ $WITH_AI == auto ]] && WITH_AI=false
      [[ $WITH_DESKTOP == auto ]] && WITH_DESKTOP=false
      [[ $WITH_XCODE == auto ]] && WITH_XCODE=false
      [[ $WITH_ALTTAB == auto ]] && WITH_ALTTAB=false
      ;;
    personal)
      [[ $WITH_EMACS == auto ]] && WITH_EMACS=true
      [[ $WITH_DROPBOX == auto ]] && WITH_DROPBOX=true
      [[ $WITH_GPG == auto ]] && WITH_GPG=true
      [[ $WITH_MEDIA == auto ]] && WITH_MEDIA=true
      [[ $WITH_CAD == auto ]] && WITH_CAD=true
      [[ $WITH_AI == auto ]] && WITH_AI=true
      [[ $WITH_DESKTOP == auto ]] && WITH_DESKTOP=true
      [[ $WITH_XCODE == auto ]] && WITH_XCODE=false
      [[ $WITH_ALTTAB == auto ]] && WITH_ALTTAB=true
      ;;
    *)
      die "Unknown profile '$PROFILE'. Expected developer or personal."
      ;;
  esac
  return 0
}

validate_only_phases() {
  local remaining
  [[ -z $ONLY_PHASES ]] && return 0

  remaining=",$ONLY_PHASES,"
  remaining=${remaining//,defaults,/,}
  remaining=${remaining//,packages,/,}
  remaining=${remaining//,toolchains,/,}
  remaining=${remaining//,dotfiles,/,}
  remaining=${remaining//,apps,/,}
  remaining=${remaining//,verify,/,}
  remaining=${remaining//,/}
  [[ -z $remaining ]] || die "Unknown phase in --only: $ONLY_PHASES"
}

phase_enabled() {
  local phase=$1
  [[ -z $ONLY_PHASES ]] && return 0
  case ",$ONLY_PHASES," in
    *",$phase,"*) return 0 ;;
    *) return 1 ;;
  esac
}

cleanup_temp_dirs() {
  local temp_dir
  for temp_dir in "${TEMP_DIRS[@]}"; do
    if [[ -n $temp_dir && -d $temp_dir && ( $temp_dir == /var/folders/* || $temp_dir == /tmp/install-macos.* ) ]]; then
      rm -rf "$temp_dir"
    fi
  done
}

new_temp_dir() {
  TEMP_DIR_RESULT=$(mktemp -d "${TMPDIR:-/tmp}/install-macos.XXXXXX")
  TEMP_DIRS+=("$TEMP_DIR_RESULT")
}

preflight() {
  [[ $(uname -s) == Darwin ]] || die "This installer supports macOS only."
  [[ $EUID -ne 0 ]] || die "Do not run this installer with sudo. Run it as the target user."
  [[ -d $HOME && -w $HOME ]] || die "Home directory is not writable: $HOME"

  log_info "Repository: $SCRIPT_DIR"
  log_info "System: $(sw_vers -productVersion) ($(uname -m))"
  log_info "Profile: $PROFILE"
  log_info "Python: $PYTHON_MANAGER $PYTHON_VERSION"
  log_info "Node: $NODE_VERSION"
  log_info "Optional groups: emacs=$WITH_EMACS dropbox=$WITH_DROPBOX gpg=$WITH_GPG media=$WITH_MEDIA cad=$WITH_CAD ai=$WITH_AI desktop=$WITH_DESKTOP xcode=$WITH_XCODE alttab=$WITH_ALTTAB"
  [[ -n $ONLY_PHASES ]] && log_info "Selected phases: $ONLY_PHASES"
  [[ $BREW_UPDATE == true ]] && log_warn "An explicit Homebrew update was requested."

  if phase_enabled packages; then
    [[ -f $SCRIPT_DIR/Brewfile ]] || die "Core Brewfile is missing from $SCRIPT_DIR"
  fi

  if [[ $DRY_RUN == false && $ASSUME_YES == false ]]; then
    local answer
    printf 'Continue with this plan? [y/N] '
    read -r answer
    case $answer in
      y | Y | yes | YES) ;;
      *) die "Cancelled by user." ;;
    esac
  fi
}

ensure_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    log_info "Xcode Command Line Tools found: $(xcode-select -p)"
    return 0
  fi

  if [[ $DRY_RUN == true ]]; then
    run xcode-select --install
    log_warn "The real run will stop until the Command Line Tools GUI installation finishes."
    return 0
  fi

  run xcode-select --install
  log_warn "Finish the Command Line Tools installation, then rerun this script."
  exit 2
}

detect_brew() {
  if command -v brew >/dev/null 2>&1; then
    BREW_BIN=$(command -v brew)
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_BIN=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW_BIN=/usr/local/bin/brew
  else
    BREW_BIN=
  fi
}

activate_homebrew() {
  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: evaluate $BREW_BIN shellenv in the installer process"
    return 0
  fi

  eval "$("$BREW_BIN" shellenv)"
}

ensure_homebrew() {
  detect_brew
  if [[ -n $BREW_BIN ]]; then
    log_info "Homebrew found: $BREW_BIN"
    activate_homebrew
    return 0
  fi

  ensure_command_line_tools

  if [[ $DRY_RUN == true ]]; then
    case $(uname -m) in
      arm64) BREW_BIN=/opt/homebrew/bin/brew ;;
      *) BREW_BIN=/usr/local/bin/brew ;;
    esac
    log_info "Dry-run: download and execute the official Homebrew installer without logging its contents"
    return 0
  fi

  new_temp_dir
  local installer=$TEMP_DIR_RESULT/homebrew-install.sh
  run curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
  run /bin/bash "$installer"

  detect_brew
  [[ -n $BREW_BIN ]] || die "Homebrew installed but brew was not found in an expected location."
  activate_homebrew
}

brew_run() {
  [[ -n $BREW_BIN ]] || ensure_homebrew
  run "$BREW_BIN" "$@"
}

install_brewfile() {
  local file=$1
  [[ -f $file ]] || die "Brewfile not found: $file"
  brew_run bundle install --no-upgrade --file="$file"
}

install_packages() {
  log_info "Installing core Homebrew packages without upgrades or cleanup…"
  ensure_command_line_tools
  ensure_homebrew

  if [[ $BREW_UPDATE == true ]]; then
    brew_run update
  fi

  install_brewfile "$SCRIPT_DIR/Brewfile"
  [[ $WITH_GPG == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.gnupg"
  [[ $WITH_MEDIA == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.media"
  [[ $WITH_CAD == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.cad"
  [[ $WITH_AI == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.ai"
  [[ $WITH_DESKTOP == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.desktop"
  [[ $WITH_DROPBOX == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.dropbox"
  [[ $WITH_XCODE == true ]] && install_brewfile "$SCRIPT_DIR/Brewfile.xcode"
  return 0
}

apply_macos_defaults() {
  [[ $SKIP_DEFAULTS == true ]] && {
    log_info "Skipping macOS defaults."
    return 0
  }

  log_info "Applying selected macOS defaults…"
  run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'
  run defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
  run defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
  run defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
  run defaults write -g NSAutomaticTextCompletionEnabled -bool false
  run defaults write -g ApplePressAndHoldEnabled -bool false
  run defaults write -g com.apple.sound.beep.flash -bool false
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run_may_fail killall Finder
}

backup_existing() {
  local destination=$1
  local relative=${destination#"$HOME"/}
  local backup_destination=$BACKUP_ROOT/$relative

  if [[ $FAIL_ON_CONFLICT == true ]]; then
    die "Managed-file conflict at $destination. Rerun without --fail-on-conflict to back it up."
  fi

  run mkdir -p "$(dirname "$backup_destination")"
  run mv "$destination" "$backup_destination"
  if [[ $DRY_RUN == true ]]; then
    log_warn "Dry-run: would back up $destination to $backup_destination"
  else
    log_warn "Backed up $destination to $backup_destination"
  fi
}

install_managed_symlink() {
  local source=$1
  local destination=$2

  [[ -e $source ]] || die "Managed source is missing: $source"

  if [[ -L $destination && $(readlink "$destination") == "$source" ]]; then
    log_info "Managed symlink already correct: $destination"
    return 0
  fi

  if [[ -e $destination || -L $destination ]]; then
    backup_existing "$destination"
  fi

  run mkdir -p "$(dirname "$destination")"
  run ln -s "$source" "$destination"
}

install_managed_copy() {
  local source=$1
  local destination=$2

  [[ -e $source ]] || die "Managed source is missing: $source"

  if [[ -f $destination ]] && cmp -s "$source" "$destination"; then
    log_info "Managed file already current: $destination"
    return 0
  fi

  if [[ -e $destination || -L $destination ]]; then
    backup_existing "$destination"
  fi

  run mkdir -p "$(dirname "$destination")"
  run cp -p "$source" "$destination"
}

install_gpg_agent_config() {
  local template=$SCRIPT_DIR/modules/gnupg/gpg-agent.macos.conf.in
  local destination=${GNUPGHOME:-$HOME/.gnupg}/gpg-agent.conf
  local pinentry

  if [[ -n $BREW_BIN && $DRY_RUN == false ]] && "$BREW_BIN" --prefix pinentry-mac >/dev/null 2>&1; then
    pinentry=$("$BREW_BIN" --prefix pinentry-mac)/bin/pinentry-mac
  elif [[ -x /opt/homebrew/bin/pinentry-mac ]]; then
    pinentry=/opt/homebrew/bin/pinentry-mac
  elif [[ -x /usr/local/bin/pinentry-mac ]]; then
    pinentry=/usr/local/bin/pinentry-mac
  elif [[ $(uname -m) == arm64 ]]; then
    pinentry=/opt/homebrew/bin/pinentry-mac
  else
    pinentry=/usr/local/bin/pinentry-mac
  fi

  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: render $template to $destination with pinentry $pinentry"
    return 0
  fi

  new_temp_dir
  local rendered=$TEMP_DIR_RESULT/gpg-agent.conf
  sed "s|@PINENTRY_PROGRAM@|$pinentry|" "$template" >"$rendered"
  chmod 600 "$rendered"
  install_managed_copy "$rendered" "$destination"
  chmod 700 "$(dirname "$destination")"
  run_may_fail gpgconf --kill gpg-agent
}

install_dotfiles() {
  log_info "Installing managed macOS dotfiles with recoverable backups…"
  install_managed_symlink "$SCRIPT_DIR/modules/zsh/.zprofile" "$HOME/.zprofile"
  install_managed_symlink "$SCRIPT_DIR/modules/zsh/.zshrc" "$HOME/.zshrc"
  install_managed_symlink "$SCRIPT_DIR/modules/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
  local karabiner_source=$SCRIPT_DIR/modules/karabiner/karabiner.json
  local karabiner_destination=$HOME/.config/karabiner/karabiner.json
  if [[ -f $karabiner_destination ]] && ! cmp -s "$karabiner_source" "$karabiner_destination" && [[ $FORCE_KARABINER_CONFIG == false ]]; then
    log_warn "Existing Karabiner config differs from the reusable baseline; leaving it untouched. Use --force-karabiner-config to back it up and replace it."
  else
    install_managed_copy "$karabiner_source" "$karabiner_destination"
  fi
  if [[ $WITH_GPG == true ]]; then
    install_gpg_agent_config
  else
    log_info "Skipping GnuPG and pinentry configuration."
  fi
}

install_nvm_and_node() {
  [[ $SKIP_NODE == true ]] && {
    log_info "Skipping Node setup."
    return 0
  }

  local nvm_dir=$HOME/.nvm

  if [[ ! -s $nvm_dir/nvm.sh ]]; then
    if [[ $DRY_RUN == true ]]; then
      log_info "Dry-run: install NVM $NVM_INSTALL_VERSION with PROFILE=/dev/null"
      log_info "Dry-run: install Node $NODE_VERSION and set it as the default"
      return 0
    fi

    new_temp_dir
    local installer=$TEMP_DIR_RESULT/nvm-install.sh
    run curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_INSTALL_VERSION/install.sh" -o "$installer"
    run env PROFILE=/dev/null NVM_DIR="$nvm_dir" bash "$installer"
  fi

  install_managed_symlink "$SCRIPT_DIR/modules/nvm/default-packages" "$nvm_dir/default-packages"

  # shellcheck disable=SC1090,SC1091
  source "$nvm_dir/nvm.sh"

  if [[ $NODE_VERSION == 'lts/*' ]]; then
    run nvm install --lts
    run nvm alias default 'lts/*'
  else
    run nvm install "$NODE_VERSION"
    run nvm alias default "$NODE_VERSION"
  fi
}

install_python() {
  [[ $SKIP_PYTHON == true ]] && {
    log_info "Skipping Python interpreter setup."
    return 0
  }

  ensure_homebrew

  case $PYTHON_MANAGER in
    pyenv)
      if ! command -v pyenv >/dev/null 2>&1; then
        brew_run install --formula pyenv
      fi

      if [[ $DRY_RUN == true ]] && ! command -v pyenv >/dev/null 2>&1; then
        log_info "Dry-run: resolve the latest patch for Python $PYTHON_VERSION, install it with pyenv, and make it global"
        return 0
      fi

      local resolved_python=$PYTHON_VERSION
      if [[ $PYTHON_VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
        resolved_python=$(pyenv latest -k "$PYTHON_VERSION")
      fi
      [[ -n $resolved_python ]] || die "Could not resolve Python version $PYTHON_VERSION with pyenv."
      log_info "Resolved Python $PYTHON_VERSION to $resolved_python"
      run pyenv install -s "$resolved_python"
      run pyenv global "$resolved_python"
      ;;
    uv)
      if ! command -v uv >/dev/null 2>&1; then
        brew_run install --formula uv
      fi
      run uv python install "$PYTHON_VERSION"
      run uv python pin --global "$PYTHON_VERSION"
      log_warn "uv mode does not install an unversioned global 'python' executable by default. Use uv run python or the versioned executable."
      ;;
    *)
      die "Unknown Python manager '$PYTHON_MANAGER'. Expected pyenv or uv."
      ;;
  esac
}

install_rust() {
  [[ $SKIP_RUST == true ]] && {
    log_info "Skipping Rust setup."
    return 0
  }

  if command -v rustup >/dev/null 2>&1; then
    log_info "rustup is already installed."
    return 0
  fi

  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: install rustup without modifying shell startup files"
    return 0
  fi

  new_temp_dir
  local installer=$TEMP_DIR_RESULT/rustup-init.sh
  run curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o "$installer"
  run sh "$installer" -y --no-modify-path

  if [[ -f $HOME/.cargo/env ]]; then
    # shellcheck disable=SC1090,SC1091
    source "$HOME/.cargo/env"
  fi
}

install_toolchains() {
  ensure_homebrew
  install_nvm_and_node
  install_python
  install_rust
}

create_finder_alias() {
  local source=$1
  local destination=$2

  if [[ -e $destination || -L $destination ]]; then
    if [[ $FORCE_APP_REPLACE == true ]]; then
      backup_existing "$destination"
    else
      log_warn "Application destination already exists; leaving it untouched: $destination (use --force-app-replace to replace it with the managed alias)"
      return 0
    fi
  fi

  if [[ $DRY_RUN == false && ! -e $source ]]; then
    log_warn "Cannot create Finder alias; source does not exist: $source"
    return 0
  fi

  run osascript -e "tell application \"Finder\" to make alias file to posix file \"$source\" at posix file \"/Applications\" with properties {name:\"$(basename "$destination")\"}"
}

install_emacs() {
  [[ $WITH_EMACS == true ]] || return 0
  ensure_homebrew

  install_managed_symlink "$SCRIPT_DIR/modules/emacs-plus/build.yml" "$HOME/.config/emacs-plus/build.yml"

  local installed_emacs_variants=
  local formula
  if [[ -x $BREW_BIN ]]; then
    while IFS= read -r formula; do
      case ${formula##*/} in
        emacs-plus | emacs-plus@*) installed_emacs_variants="$installed_emacs_variants $formula" ;;
      esac
    done < <("$BREW_BIN" list --formula --full-name 2>/dev/null)
  fi

  local target_available=false
  case " $installed_emacs_variants " in
    *" d12frosted/emacs-plus/emacs-plus@master "* | *" emacs-plus@master "*) target_available=true ;;
  esac

  if [[ -n ${installed_emacs_variants// } ]]; then
    if [[ $FORCE_EMACS_REINSTALL == true ]]; then
      log_warn "Explicit Emacs replacement requested; removing installed Emacs Plus variant(s):$installed_emacs_variants"
      for formula in $installed_emacs_variants; do
        brew_run uninstall --formula "$formula"
      done
      target_available=false
    elif [[ $target_available == true ]]; then
      log_info "Emacs Plus master is already installed; leaving it untouched."
    else
      log_warn "A different Emacs Plus variant is installed and will not be replaced:$installed_emacs_variants. Use --force-emacs-reinstall for an explicit transition to master."
    fi
  fi

  if [[ $target_available == false && ( -z ${installed_emacs_variants// } || $FORCE_EMACS_REINSTALL == true ) ]]; then
    brew_run tap d12frosted/emacs-plus
    brew_run trust d12frosted/emacs-plus
    brew_run install emacs-plus@master --with-dbus --with-debug --with-mailutils --with-xwidgets
    target_available=true
  fi

  if [[ $target_available == false ]]; then
    log_warn "Skipping Emacs master Finder aliases because master was not installed."
  elif [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: create Finder aliases for Emacs.app and Emacs Client.app"
  else
    local prefix
    prefix=$("$BREW_BIN" --prefix emacs-plus@master)
    create_finder_alias "$prefix/Emacs.app" /Applications/Emacs.app
    create_finder_alias "$prefix/Emacs Client.app" "/Applications/Emacs Client.app"
  fi

  if [[ $SKIP_RUST == false ]]; then
    if [[ $DRY_RUN == true ]]; then
      log_info "Dry-run: cargo install --locked emacs-lsp-booster if missing"
    elif command -v cargo >/dev/null 2>&1 && ! command -v emacs-lsp-booster >/dev/null 2>&1; then
      run cargo install --locked emacs-lsp-booster
    fi
  fi
}

install_default_browser() {
  if ! command -v defaultbrowser >/dev/null 2>&1; then
    if [[ $DRY_RUN == true ]]; then
      log_info "Dry-run: set Google Chrome as the default browser with defaultbrowser"
    else
      log_warn "defaultbrowser is unavailable; cannot set Chrome as default."
    fi
    return 0
  fi

  run open -a "Google Chrome"
  run defaultbrowser chrome
}

install_app_archive() {
  local archive=$1
  local app_name=$2
  local expected_sha=${3-}
  local destination=/Applications/$app_name

  if [[ ! -f $archive ]]; then
    log_warn "Application archive is missing; skipping $app_name: $archive"
    return 0
  fi

  if [[ -n $expected_sha ]]; then
    local actual_sha
    actual_sha=$(shasum -a 256 "$archive" | awk '{print $1}')
    [[ $actual_sha == "$expected_sha" ]] || die "Checksum mismatch for $archive: expected $expected_sha, got $actual_sha"
  fi

  if unzip -Z1 "$archive" | LC_ALL=C grep -Eq '(^/|(^|/)\.\.(/|$))'; then
    die "Archive contains an unsafe absolute or parent-relative path: $archive"
  fi

  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: verify, extract, and install $archive as $destination"
    return 0
  fi

  new_temp_dir
  local extract_dir=$TEMP_DIR_RESULT/extracted
  run mkdir -p "$extract_dir"
  run ditto -x -k "$archive" "$extract_dir"

  local source_app=$extract_dir/$app_name
  [[ -d $source_app ]] || die "Archive does not contain the expected top-level $app_name: $archive"

  if [[ -e $destination ]]; then
    local source_version installed_version
    source_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$source_app/Contents/Info.plist" 2>/dev/null || true)
    installed_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$destination/Contents/Info.plist" 2>/dev/null || true)
    if [[ -n $source_version && $source_version == "$installed_version" ]]; then
      log_info "$app_name $source_version is already installed."
      return 0
    fi
    [[ $FORCE_APP_REPLACE == true ]] || die "$destination already exists with a different version. Use --force-app-replace to back it up and replace it."
    backup_existing "$destination"
  fi

  run ditto "$source_app" "$destination"
}

install_optional_apps() {
  install_default_browser
  install_emacs

  if [[ $WITH_ALTTAB == true ]]; then
    install_app_archive "$ALTTAB_ARCHIVE" AltTab.app "$ALTTAB_SHA256"
  fi

  if [[ $WITH_MEDIA == true ]]; then
    if [[ -n $MPV_APP_ARCHIVE ]]; then
      install_app_archive "$MPV_APP_ARCHIVE" mpv.app
    else
      log_info "mpv CLI/libmpv requested; no mpv.app archive supplied. The deprecated stolendata-mpv cask will not be installed."
    fi
  fi
  return 0
}

verify_command() {
  local command_name=$1
  if command -v "$command_name" >/dev/null 2>&1; then
    log_info "Verified command: $command_name"
  else
    log_warn "Command not found: $command_name"
  fi
}

verify_setup() {
  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run: verify Brewfiles, commands, managed files, browser, GPG pinentry and shell syntax"
    return 0
  fi

  if [[ -n $BREW_BIN ]]; then
    if "$BREW_BIN" bundle check --file="$SCRIPT_DIR/Brewfile" >/dev/null 2>&1; then
      log_info "Core Brewfile is satisfied."
    else
      log_warn "Core Brewfile is not fully satisfied."
    fi
  fi

  verify_command git
  verify_command gh
  verify_command docker
  verify_command node
  verify_command uv
  if [[ $WITH_GPG == true ]]; then
    verify_command gpg
    verify_command pass
  fi

  if [[ $PYTHON_MANAGER == pyenv && $SKIP_PYTHON == false ]]; then
    verify_command pyenv
  fi
  [[ $WITH_MEDIA == true ]] && verify_command mpv
  [[ $WITH_MEDIA == true ]] && verify_command ffmpeg
  [[ $WITH_EMACS == true ]] && verify_command emacs

  zsh -n "$SCRIPT_DIR/modules/zsh/.zshrc"
  log_info "Managed Zsh configuration passed syntax validation."
  log_warn "Karabiner still requires Accessibility and Input Monitoring approval in System Settings."
  log_warn "Docker Desktop may require a first launch before the docker command becomes available."
}

main() {
  parse_args "$@"
  set_profile_defaults
  validate_only_phases
  trap cleanup_temp_dirs EXIT

  preflight

  if phase_enabled defaults; then
    apply_macos_defaults
  fi
  if phase_enabled packages; then
    install_packages
  fi
  if phase_enabled toolchains; then
    install_toolchains
  fi
  if phase_enabled dotfiles; then
    install_dotfiles
  fi
  if phase_enabled apps; then
    install_optional_apps
  fi
  if phase_enabled verify; then
    detect_brew
    verify_setup
  fi

  if [[ $DRY_RUN == true ]]; then
    log_info "Dry-run complete; no requested mutations were executed."
  else
    log_info "macOS setup complete."
    if [[ -d $BACKUP_ROOT ]]; then
      log_info "Backups created under $BACKUP_ROOT"
    fi
  fi
}

main "$@"
