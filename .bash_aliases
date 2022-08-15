# Aliases
# alias alias_name="command_to_run"

# Long format list
alias ll="ls -la"

# Print my public IP
alias myip='curl ipinfo.io/ip'
alias Install='sudo apt-get install'
alias Update='sudo apt-get update'
alias Upgrade='sudo apt-get upgrade'
alias Search='apt-cache search'
alias Autoremove='sudo apt-get autoremove'
alias Autoclean='sudo apt-get autoclean'
alias Purge='sudo apt-get remove –purge'
alias x='exit'
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
alias cpv='rsync -ah --info=progress2'
alias viewnior='viewnior --fullscreen'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
