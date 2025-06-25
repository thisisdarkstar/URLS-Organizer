#!/usr/bin/env bash
#
# URLS-Organizer
# ----------------
# Organize a list of URLs or hostnames by their root domain, grouping all subdomains together.
#
# Author:      Your Name <your.email@example.com>
# Repository:  https://github.com/yourusername/URLS-Organizer
# License:     MIT
# Version:     1.0.0
# Date:        2025-06-25
#
# Usage:       ./script.sh input.txt
#              cat input.txt | ./script.sh
#
# Description:
#   - Extracts hostnames from URLs (handles protocols, ports, credentials, queries, fragments)
#   - Groups subdomains under their root domain (supports SLDs like .co.uk)
#   - Deduplicates subdomains
#   - Skips IPs, localhost, and comments
#   - Outputs each root domain as a folder with a subdomains.txt file
#
# ----------------

set -o errexit
set -o nounset
set -o pipefail

extract_hostname() {
  local raw="$1"
  raw="${raw#*://}"
  raw="${raw#*@}"
  raw="${raw%%\?*}"
  raw="${raw%%\#*}"
  raw="${raw%%/*}"
  raw="${raw%%:*}"
  echo "$raw"
}

get_root_domain() {
  local hostname="$1"
  local common_slds=" co com org net ac gov edu "
  IFS='.' read -r -a parts <<< "$hostname"
  local count="${#parts[@]}"
  [[ $count -lt 2 ]] && return
  local second_last="${parts[count-2]}"
  if [[ $count -ge 3 ]] && [[ " $common_slds " == *" $second_last "* ]]; then
    echo "${parts[count-3]}.${parts[count-2]}.${parts[count-1]}"
  else
    echo "${parts[count-2]}.${parts[count-1]}"
  fi
}

main() {
  local input="${1:-/dev/stdin}"

  # Show usage if no file is passed and stdin is not piped
  if [[ "$input" == "/dev/stdin" ]] && [ -t 0 ]; then
    echo "Usage: $0 <input_file>" >&2
    echo "       cat input.txt | $0" >&2
    exit 1
  fi

  [[ ! -r "$input" ]] && echo "Error: Cannot read file '$input'" >&2 && exit 1

  declare -A root_to_subs

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    local host
    host=$(extract_hostname "$line")
    [[ -z "$host" || ! "$host" == *.* || "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ || "$host" == "localhost" ]] && continue
    local root
    root=$(get_root_domain "$host")
    [[ -z "$root" ]] && continue
    if [[ -z "${root_to_subs[$root]+exists}" ]] || [[ " ${root_to_subs[$root]} " != *" $host "* ]]; then
      root_to_subs["$root"]+="$host "
    fi
  done < "$input"

  if [[ -z "${root_to_subs[*]+exists}" ]]; then
    echo "No valid domains were processed."
    return
  fi

  echo "Processing complete. Organizing subdomains..."
  for root in "${!root_to_subs[@]}"; do
    echo "  → $root"
    mkdir -p "$root"
    local subs="${root_to_subs[$root]}"
    tr ' ' '\n' <<< "${subs% }" > "$root/subdomains.txt"
  done
  echo "Done."
}

main "$@"