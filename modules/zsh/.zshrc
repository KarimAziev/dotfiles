setopt nonomatch
setopt HIST_IGNORE_DUPS SHARE_HISTORY

# Homebrew must never mutate the machine as a side effect of an install.
export HOMEBREW_NO_ASK=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_UPGRADE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_AUTOREMOVE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BUNDLE_NO_UPGRADE=1

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

autoload -Uz colors && colors

if command -v tput >/dev/null 2>&1; then
  terminal_colors=$(tput colors 2>/dev/null || printf '0')
else
  terminal_colors=0
fi

if (( terminal_colors >= 256 )); then
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{75}%~%f%b%(!.#.$) '
elif (( terminal_colors >= 8 )); then
  PROMPT='%B%F{green}%n@%m%f%b:%B%F{cyan}%~%f%b%(!.#.$) '
else
  PROMPT='%B%n@%m:%~%(!.#.$)%b '
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.cargo/bin" $path)

if command -v brew >/dev/null 2>&1; then
  brew_prefix=$(brew --prefix)
  fpath=("$brew_prefix/share/zsh/site-functions" $fpath)

  for gnu_bin_dir in \
    "$brew_prefix/opt/coreutils/libexec/gnubin" \
    "$brew_prefix/opt/findutils/libexec/gnubin" \
    "$brew_prefix/opt/gnu-sed/libexec/gnubin"; do
    [[ -d "$gnu_bin_dir" ]] && path=("$gnu_bin_dir" $path)
  done

  if [[ -f "$brew_prefix/etc/bash_completion.d/git-prompt.sh" ]]; then
    source "$brew_prefix/etc/bash_completion.d/git-prompt.sh"
  fi

  if [[ -d "$brew_prefix/opt/liquibase/libexec" ]]; then
    export LIQUIBASE_HOME="$brew_prefix/opt/liquibase/libexec"
  fi
fi

if [[ -t 0 ]]; then
  export GPG_TTY=$(tty)
fi

[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

if command -v emacs >/dev/null 2>&1; then
  export EDITOR=emacs
  export VISUAL=emacs
else
  export EDITOR=vi
  export VISUAL=vi
fi
export PAGER=less
export LSP_USE_PLISTS=true

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - zsh)"

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

autoload -Uz compinit
compinit

if command -v terraform >/dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v terraform)" terraform
fi
