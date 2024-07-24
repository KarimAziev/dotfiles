# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return ;;
esac

# Don't put duplicate lines or spaces in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# History size settings.
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command.
shopt -s checkwinsize

# Enable color support of ls and use aliases.
if [ -x /usr/bin/dircolors ]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color | *-256color) color_prompt=yes ;;
esac

# Enable color prompt if set.
# We are disabling ShellCheck warning SC2154 here because 'debian_chroot'
# is set by the system in '/etc/bash.bashrc' or '/etc/profile' for Debian-based
# systems. This setup is external to the user's individual .bashrc file.
# The usage below is safe: if 'debian_chroot' is not set, the expansion
# results in an empty string, causing no disruption to the prompt.

# shellcheck disable=SC2154
if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt

# Alert alias for notifying when a command completes.
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'' )"'

# Initialize bash completion, if it's not already enabled in /etc/bash.bashrc.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set GPG_TTY to allow passphrase input.
GPG_TTY=$(tty)
export GPG_TTY

# Set Docker host to allow non-root user access.
DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
export DOCKER_HOST

# Load .bash_aliases if it exists.
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

# Load Rust environment.
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Custom PATH settings for local installs and user-specific programs.
# Append or prepend new directories to PATH as per requirement.
custom_paths=(
  "$HOME/.local/bin"
)

for path in "${custom_paths[@]}"; do
  [[ -d "$path" ]] && PATH="$path:$PATH"
done

# NVM (Node.js Version Manager) initialization.
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090,SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# shellcheck disable=SC1090,SC1091
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# Enable npm command completion.
if type npm &> /dev/null && type complete &> /dev/null; then
  NPM_COMPLETION="$(npm completion)"
  if [ -n "$NPM_COMPLETION" ]; then
    eval "$NPM_COMPLETION"
  fi
fi

export LSP_USE_PLISTS=true

# Python Version Manager (pyenv) installation and setup
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

eval "$(direnv hook bash)"

# Java Version Manager (SDKMAN) installation and setup
# shellcheck disable=SC1090,SC1091
export SDKMAN_DIR="$HOME/.sdkman"
# shellcheck disable=SC1090,SC1091
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

[ -f "/home/km/.ghcup/env" ] && . "/home/km/.ghcup/env" # ghcup-env

# Export PATH environment variable - added by script
export PATH
