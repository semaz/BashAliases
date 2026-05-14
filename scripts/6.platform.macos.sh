#!/usr/bin/env bash

alias edit='open -e'

alias flushDNS='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

alias finderHiddenShow='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias finderHiddenHide='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'

alias rmDS='rmFileRecursively ".DS_Store"'
alias rmZoneIdentifier='rmFileRecursively "Zone.Identifier"'