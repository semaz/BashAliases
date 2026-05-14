#!/usr/bin/env bash

# PATH
export PATH=/usr/local/bin:$PATH

# COLOR
force_color_prompt=yes
export CLICOLOR=1

case $SHELL in
  */zsh)
     PS1='%B%F{yellow}%n%f@%F{green}%m%f:%F{blue}%~%f%b '
     ;;
  */bash)
     export PS1='\[\e[38;5;228;1m\]\u\[\e[39m\]@\[\e[38;5;70m\]\H\[\e[0m\]:\[\e[38;5;27;1m\]\w \[\e[0m\]'
     ;;
  esac

# helper functions
command_exists () { type "$1" &> /dev/null ; }

get_config_path() {
  case $SHELL in
  */zsh)
     if [ -f ~/.zshrc ]
        then
           echo ".zshrc";
        elif [ -f ~/.zprofile ]
        then
           echo ".zprofile";
        else
           echo ".zshenv";
        fi
     ;;
  */bash)
     if [ -f ~/.bash_aliases ]
        then
           echo ".bash_aliases";
        elif [ -f ~/.bash_profile ]
        then
           echo ".bash_profile";
        elif [ -f ~/.bashrc ]
        then
           echo ".bashrc";
        elif [ -f ~/.bash_rc ]
        then
           echo ".bash_rc";
        else
           echo "Can't find bash config file";
           exit 1;
        fi
     ;;
  *)
    echo "Unknown shell";
    exit 1;
  esac
}

# motd progress bar helper
_motd_bar() {
    local pct=$1 w=${2:-16} col="${3:-\033[0;32m}"
    local R='\033[0m' DIM='\033[2m'
    local filled empty i out
    (( filled = pct * w / 100 ))
    (( empty  = w - filled ))
    out=""
    for ((i=0; i<filled; i++)); do out+="${col}▓${R}"; done
    for ((i=0; i<empty;  i++)); do out+="${DIM}░${R}"; done
    printf "%s" "$out"
}

# load color helper — green/yellow/red relative to cpu count
_motd_lc() {
    awk -v v="$1" -v c="$2" 'BEGIN {
        r = v / c
        if (r >= 0.9) printf "\033[0;31m"
        else if (r >= 0.7) printf "\033[0;33m"
        else printf "\033[0;32m"
    }'
}

# uptime formatter — returns "3d 4h 12m" using /proc/uptime when available
_motd_uptime() {
    if [ -f /proc/uptime ]; then
        local secs days hours mins out
        secs=$(awk '{printf "%d", $1}' /proc/uptime)
        days=$(( secs / 86400 ))
        hours=$(( (secs % 86400) / 3600 ))
        mins=$(( (secs % 3600) / 60 ))
        out=""
        [ $days -gt 0 ] && out="${days}d "
        { [ $days -gt 0 ] || [ $hours -gt 0 ]; } && out="${out}${hours}h "
        out="${out}${mins}m"
        printf "%s" "$out"
    else
        uptime | sed 's/.*up //;s/,\s*[0-9]* user.*//'
    fi
}

# motd — session info displayed on SSH login
motd() {
    local R='\033[0m' B='\033[1m' DIM='\033[2m'
    local CY='\033[0;36m' GR='\033[0;32m' YE='\033[0;33m' RE='\033[0;31m' WH='\033[1;37m'
    local bar_col warn pct

    # dynamic separator matching terminal width
    local cols; cols=$(tput cols 2>/dev/null || echo 60)
    local sep; sep=$(printf '━%.0s' $(seq 1 "$cols"))
    local thin; thin=$(printf '─%.0s' $(seq 1 $(( cols - 4 ))))

    # os/distro name from os-release
    local os=""
    [ -f /etc/os-release ] && os=$(. /etc/os-release; echo "$PRETTY_NAME")

    echo -e "${CY}${B}${sep}${R}"
    echo -e "  ${WH}${B}$(hostname)${R}  ${DIM}$(id -un)${R}  ${DIM}${os}${R}"
    echo -e "  $(date '+%a %Y-%m-%d  %H:%M:%S %Z')"
    echo -e "${CY}${B}${sep}${R}"

    # uptime
    echo -e "  ${B}${YE}↑${R} $(printf '%-10s' 'Uptime')$(_motd_uptime)"

    # load average with color relative to cpu count
    if [ -f /proc/loadavg ]; then
        local cpus load1 load5 load15 lc1 lc5 lc15
        cpus=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo 1)
        read -r load1 load5 load15 _ < /proc/loadavg
        lc1=$(_motd_lc "$load1" "$cpus")
        lc5=$(_motd_lc "$load5" "$cpus")
        lc15=$(_motd_lc "$load15" "$cpus")
        echo -e "  ${B}${CY}≡${R} $(printf '%-10s' 'Load')${lc1}${load1}${R}  ${lc5}${load5}${R}  ${lc15}${load15}${R}  ${DIM}(1/5/15 min)${R}"
    fi

    # memory — use -m to avoid Gi/Mi units, format manually
    if command -v free &>/dev/null; then
        local mem_str swap_str swap_total
        pct=$(free -m | awk '/Mem:/ {printf "%d", $3/$2*100}')
        mem_str=$(free -m | awk '/Mem:/ {
            used=$3; total=$2
            if (total >= 1024) printf "%.1fG / %.1fG", used/1024, total/1024
            else printf "%dM / %dM", used, total
        }')
        (( pct >= 90 )) && bar_col='\033[0;31m' || { (( pct >= 75 )) && bar_col='\033[0;33m' || bar_col='\033[0;32m'; }
        (( pct >= 90 )) && warn="${RE}" || { (( pct >= 75 )) && warn="${YE}" || warn=""; }
        echo -e "  ${B}${RE}▣${R} ${warn}$(printf '%-10s' 'Memory')${R}$(_motd_bar "$pct" 16 "$bar_col")  ${warn}${pct}%${R}  ${mem_str}"

        # swap — only if configured
        swap_total=$(free -m | awk '/Swap:/ {print $2}')
        if (( swap_total > 0 )); then
            pct=$(free -m | awk '/Swap:/ {printf "%d", $3/$2*100}')
            swap_str=$(free -m | awk '/Swap:/ {
                used=$3; total=$2
                if (total >= 1024) printf "%.1fG / %.1fG", used/1024, total/1024
                else printf "%dM / %dM", used, total
            }')
            (( pct >= 90 )) && bar_col='\033[0;31m' || { (( pct >= 75 )) && bar_col='\033[0;33m' || bar_col='\033[0;32m'; }
            (( pct >= 90 )) && warn="${RE}" || { (( pct >= 75 )) && warn="${YE}" || warn=""; }
            echo -e "  ${B}${CY}▣${R} ${warn}$(printf '%-10s' 'Swap')${R}$(_motd_bar "$pct" 16 "$bar_col")  ${warn}${pct}%${R}  ${swap_str}"
        fi
    fi

    # disk
    pct=$(df / | awk 'NR==2 {gsub(/%/,"",$5); print $5+0}')
    (( pct >= 90 )) && bar_col='\033[0;31m' || { (( pct >= 75 )) && bar_col='\033[0;33m' || bar_col='\033[0;32m'; }
    (( pct >= 90 )) && warn="${RE}" || { (( pct >= 75 )) && warn="${YE}" || warn=""; }
    echo -e "  ${B}${YE}◉${R} ${warn}$(printf '%-10s' 'Disk')${R}$(_motd_bar "$pct" 16 "$bar_col")  ${warn}${pct}%${R}  ${DIM}$(df -h / | awk 'NR==2 {print $4 " free / " $2 " total"}')${R}"

    # thin divider between resource metrics and system info
    echo -e "  ${DIM}${thin}${R}"

    # IP address
    local ip
    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -n "$ip" ] && echo -e "  ${B}${WH}◎${R} $(printf '%-10s' 'IP')${ip}"

    # logged in users — count unique names to match displayed list
    local users user_names
    user_names=$(who | awk '{print $1}' | sort -u | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
    users=$(who | awk '{print $1}' | sort -u | wc -l | tr -d ' ')
    echo -e "  ${B}${GR}◈${R} $(printf '%-10s' 'Users')${users} logged in: ${DIM}${user_names}${R}"

    # failed systemd services
    if command -v systemctl &>/dev/null; then
        local failed
        failed=$(systemctl list-units --failed --no-legend 2>/dev/null | wc -l | tr -d ' ')
        if (( failed > 0 )); then
            echo -e "  ${B}${RE}✖${R} $(printf '%-10s' 'Services')${RE}${failed} failed${R}  ${DIM}(systemctl --failed)${R}"
        else
            echo -e "  ${B}${GR}✔${R} $(printf '%-10s' 'Services')${GR}all running${R}"
        fi
    fi

    echo -e "${CY}${B}${sep}${R}"
}
