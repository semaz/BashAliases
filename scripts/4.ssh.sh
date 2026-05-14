#!/usr/bin/env bash

# Resolve # @include directives recursively before injection
_sshrc_resolve() {
    local file="$1" base="$2" line inc
    while IFS= read -r line || [ -n "$line" ]; do
        inc=$(printf '%s' "$line" | sed -En 's/^[[:space:]]*#[[:space:]]*@include[[:space:]]+(.+)$/\1/p')
        if [ -n "$inc" ]; then
            [ -f "$base/$inc" ] && _sshrc_resolve "$base/$inc" "$base"
        else
            printf '%s\n' "$line"
        fi
    done < "$file"
}

ssh() {
    local host=""
    for arg in "$@"; do
        [[ "$arg" != -* ]] && [[ -z "$host" ]] && host="$arg"
    done
    local sshrc=""
    local SSHRC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )/.." && pwd )"
    if [ -f "$SSHRC_PATH/sshrc.sh" ]; then
        sshrc=$(_sshrc_resolve "$SSHRC_PATH/sshrc.sh" "$SSHRC_PATH" \
            | grep -v '^\s*#' | grep -v '^\s*$' \
            | base64 | tr -d '\n')
    fi

    /usr/bin/ssh -t "$@" "bash --rcfile <(
        [ -f ~/.bashrc ] && cat ~/.bashrc
        echo 'export SSHRC_HOST=$host'
        echo '$sshrc' | base64 -d
    )"
}
