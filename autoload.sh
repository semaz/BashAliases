#!/usr/bin/env bash

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/scripts"

case "$(uname -s)" in
  Darwin) _OS_SUFFIX="macos" ;;
  Linux)  _OS_SUFFIX="linux" ;;
  *)      _OS_SUFFIX="" ;;
esac

# universal — all except OS-specific files
for f in "$SCRIPTS_DIR"/*.sh; do
    [[ "$f" == *.macos.sh ]] && continue
    [[ "$f" == *.linux.sh ]] && continue
    source "$f"
done

# OS-specific
if [[ -n "$_OS_SUFFIX" ]]; then
    for f in "$SCRIPTS_DIR"/*."$_OS_SUFFIX".sh; do
        [[ -f "$f" ]] && source "$f"
    done
fi

unset _OS_SUFFIX
