#!/usr/bin/env bash

# PATH
export PATH=/usr/local/bin:$PATH

# COLOR
force_color_prompt=yes
export CLICOLOR=1
#export PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

case $SHELL in
  */zsh)
     PS1='%B%F{yellow}%n%f@%F{green}%m%f:%F{blue}%~%f%b '
     ;;
  */bash)
     export PS1='\[\e[38;5;228;1m\]\u\[\e[39m\]@\[\e[38;5;70m\]\H\[\e[0m\]:\[\e[38;5;27;1m\]\w \[\e[0m\]'
     ;;
  esac

# EDITOR
export EDITOR=$(which nano)

USER="`id -un`"
