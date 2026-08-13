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

# ssh option letters that consume a value, either glued (-p2222) or as the next argument (-p 2222)
_SSHRC_OPTS_WITH_VALUE="BbcDEeFIiJLlmOoPpQRSWw"

# Split ssh arguments into options, target and remote command.
# Writes the result into _SSHRC_TARGET and _SSHRC_HAS_CMD, declared as local by the caller.
_sshrc_parse_args() {
    _SSHRC_TARGET=""
    _SSHRC_HAS_CMD=0
    local arg char i len skip=0
    for arg in "$@"; do
        if [ "$skip" -eq 1 ]; then
            skip=0
            continue
        fi
        case "$arg" in
            -*)
                i=1
                len=${#arg}
                # walk the bundle: the first value-taking letter eats the rest of the argument,
                # or the next argument when nothing follows it
                while [ "$i" -lt "$len" ]; do
                    char=${arg:$i:1}
                    case "$_SSHRC_OPTS_WITH_VALUE" in
                        *"$char"*)
                            [ "$((i + 1))" -ge "$len" ] && skip=1
                            i=$len
                            ;;
                        *)
                            i=$((i + 1))
                            ;;
                    esac
                done
                ;;
            *)
                if [ -z "$_SSHRC_TARGET" ]; then
                    _SSHRC_TARGET="$arg"
                else
                    _SSHRC_HAS_CMD=1
                fi
                ;;
        esac
    done
}

ssh() {
    local _SSHRC_TARGET _SSHRC_HAS_CMD
    _sshrc_parse_args "$@"

    # A remote command was given, so injection is impossible: ssh joins everything after the
    # target into a single command line and the injected bash would land there as arguments
    if [ "$_SSHRC_HAS_CMD" -eq 1 ]; then
        /usr/bin/ssh "$@"
        return $?
    fi

    local host="${_SSHRC_TARGET##*@}"
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
