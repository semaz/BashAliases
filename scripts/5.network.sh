#!/usr/bin/env bash

alias myip='curl -s https://ipinfo.io/ip'
alias edithosts='sudo "$EDITOR" /etc/hosts'

command_exists mtr && alias trace='mtr'
