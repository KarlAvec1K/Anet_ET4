#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 TEMPLATE OUTPUT USER SERIAL_BY_ID TRUSTED_LAN_CIDR HOSTNAME" >&2
    exit 2
fi

template=$1
output=$2
user=$3
serial=$4
lan=$5
hostname=$6

[[ "$user" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || { echo "Invalid user." >&2; exit 2; }
[[ "$serial" == /dev/serial/by-id/* ]] || { echo "Invalid serial path." >&2; exit 2; }
[[ "$lan" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$ ]] || { echo "Invalid IPv4 CIDR." >&2; exit 2; }
[[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || { echo "Invalid hostname." >&2; exit 2; }

mkdir -p "$(dirname "$output")"
sed \
    -e "s|__ANET_USER__|$user|g" \
    -e "s|__SERIAL_BY_ID__|$serial|g" \
    -e "s|__TRUSTED_LAN_CIDR__|$lan|g" \
    -e "s|__HOSTNAME__|$hostname|g" \
    "$template" > "$output"

if grep -q '__[A-Z_][A-Z_]*__' "$output"; then
    echo "Unresolved template placeholder in $output." >&2
    exit 1
fi
