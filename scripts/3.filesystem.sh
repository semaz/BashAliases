#!/usr/bin/env bash

# EDITOR
export EDITOR=$(which nano)

# Detect which `ls` flavor is in use
export LS_OPTIONS='--color=auto'
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # macOS `ls`
	colorflag="-G"
fi

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
alias l.='ls -d .*'
alias ll='ls -lha'
# List only directories
alias lsd="ls -lF | grep --color=never '^d'"

# grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# find
f() {
  find . -name "*$1*"
}

# Allows you to search for any text in any file recursively.
# Usage: ft "my string" *.php
ft() {
  find . -name "$2" -exec grep -il "$1" {} \;
}

alias fixEol='sed -i "s/\r$//"'

alias tf='tail -f'

alias numFiles='echo $(ls -1 | wc -l)'

rmFileRecursively() {
  find ./ -name "*$1*" -print0 | xargs -0 -I {} /bin/rm -rf "{}"
}

alias size='du -sh'                             # get folder size
alias sizer='du -h -c'                          # get and print folder size for all folders, recursively
alias disks='df -H -l'                          # show available disk space

# cd
alias ~='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

cdl() { cd "$@"; ll; }

# archive
function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
 else
    if [ -f "$1" ] ; then
        # NAME=${1%.*}
        # mkdir $NAME && cd $NAME
        case $1 in
          *.tar.bz2)   tar xvjf "$1"    ;;
          *.tar.gz)    tar xvzf "$1"    ;;
          *.tar.xz)    tar xvJf "$1"    ;;
          *.lzma)      unlzma "$1"      ;;
          *.bz2)       bunzip2 "$1"     ;;
          *.rar)       unrar x -ad "$1" ;;
          *.gz)        gunzip "$1"      ;;
          *.tar)       tar xvf "$1"     ;;
          *.tbz2)      tar xvjf "$1"    ;;
          *.tgz)       tar xvzf "$1"    ;;
          *.zip)       unzip "$1"       ;;
          *.Z)         uncompress "$1"  ;;
          *.7z)        7z x "$1"        ;;
          *.xz)        unxz "$1"        ;;
          *.exe)       cabextract "$1"  ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}
