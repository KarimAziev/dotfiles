#!/bin/bash
set -e
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

LOCALE="en_US.UTF-8"
LANGUAGE="en_US:en"
DRY_RUN=${DRY_RUN:-false}

log_info() {
  printf "\033[32m[INFO]\033[0m %s\n" "$1"
}

log_error() {
  printf "\033[31m[ERROR]\033[0m %s\n" "$1" >&2
}

log_warn() {
  printf "\033[1;33m[WARNING]\033[0m %s\n" "$1" >&2
}

usage() {
  cat << EOF
Generates locales and configures the system's default language settings.

Usage: $0 [OPTIONS]

Options:
  -l, --locale LOCALE             Set the locale to configure (default: ${LOCALE})
  -L, --language LANGUAGE         Set the LANGUAGE environment variable (default: ${LANGUAGE})
  -d, --dry-run                   Run in dry-run mode: print commands instead of executing them.
  -h, --help                      Display this help message and exit.

Example:
  sudo $0 --locale fr_FR.UTF-8 --language "fr_FR:fr"
EOF
}

run_cmd() {
  if [ "$DRY_RUN" = true ]; then
    log_info "Dry-run: $*"
  else
    log_info "Executing: $*"
    "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d | --dry-run)
      DRY_RUN=true
      shift
      ;;
    -l | --locale)
      if [ -n "$2" ]; then
        LOCALE="$2"
        shift 2
      else
        log_error "Option $1 requires an argument."
        usage
        exit 1
      fi
      ;;
    -L | --language)
      if [ -n "$2" ]; then
        LANGUAGE="$2"
        shift 2
      else
        log_error "Option $1 requires an argument."
        usage
        exit 1
      fi
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [ "$EUID" -ne 0 ]; then
  log_error "This script must be run as root. Try using sudo."
  exit 1
fi

log_info "Starting locale setup for system with locale: $LOCALE"

if [ ! -f /etc/locale.gen ]; then
  log_error "/etc/locale.gen not found. Aborting locale setup."
  exit 1
fi

backup_file="/etc/locale.gen.bak.$(date +%Y%m%d%H%M%S)"
log_info "Backing up current locale configuration to $backup_file"
run_cmd cp -p /etc/locale.gen "$backup_file"

# the locale.gen file typically has lines such as:
#   # en_US.UTF-8 UTF-8
# to enable the desired locale we uncomment that line.
escaped_locale=$(printf '%s\n' "$LOCALE" | sed 's/\./\\./g')
log_info "Enabling ${LOCALE} in /etc/locale.gen..."
run_cmd sed -i "/^# *${escaped_locale} UTF-8/s/^# *//" /etc/locale.gen

log_info "Generating locales..."
run_cmd locale-gen

log_info "Setting default system language to ${LOCALE}..."
if [ "$DRY_RUN" = true ]; then
  log_info "Dry-run: Would update /etc/default/locale with the following content:"
  log_info "LANG=${LOCALE}"
  log_info "LANGUAGE=${LANGUAGE}"
else
  tee /etc/default/locale > /dev/null << EOF
LANG=${LOCALE}
LANGUAGE=${LANGUAGE}
EOF
fi

run_cmd update-locale LANG="${LOCALE}" LANGUAGE="${LANGUAGE}"

log_info "Locale setup complete. The system is now configured to use ${LOCALE}."

exit 0
