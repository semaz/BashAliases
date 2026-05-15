#!/usr/bin/env bash

alias edit='open -e'
alias dirspace='du -ahd 1 | sort -hr'

alias flushDNS='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

alias finderHiddenShow='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias finderHiddenHide='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

alias rmDS='rmFileRecursively ".DS_Store"'
alias rmZoneIdentifier='rmFileRecursively "Zone.Identifier"'