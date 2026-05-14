#!/usr/bin/env bash

alias c='clear'
alias g='git'

# ps
alias ps2='ps -ef | grep -v $$ | grep -i '
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psme='ps -ef | grep $USER --color=always '

# other
alias hg='history|grep '

# php
alias cmp='composer'
alias cmpdu='composer dump-autoload'
alias cmpin='composer install'
alias cmpup='composer update -W'
alias sf='php bin/console'
alias cept='php vendor/bin/codecept'
alias phinx='php vendor/bin/phinx'
