#!/bin/bash

SCRIPTS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd )"

source "$SCRIPTS_PATH/scripts/1.term.sh"

if grep -q "$SCRIPTS_PATH/autoload.sh" ~/"$(get_config_path)";
then
    echo "Scripts already installed."
    exit 0;
fi;

tee -a ~/"$(get_config_path)" >/dev/null <<EOF

# BashScripts autoload
source "$SCRIPTS_PATH/autoload.sh"
EOF

exec "$SHELL" -l
