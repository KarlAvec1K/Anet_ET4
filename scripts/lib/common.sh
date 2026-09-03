#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

require_root() {
    [ "$(id -u)" -eq 0 ] || die "This operation must be run as root."
}

validate_user() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] || die "Invalid Linux user: $1"
}

validate_serial() {
    [[ "$1" == /dev/serial/by-id/* ]] || die "Serial path must be under /dev/serial/by-id/."
}

validate_ipv4_cidr() {
    [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[12][0-9]|3[0-2])$ ]] || die "Trusted LAN must be an IPv4 CIDR."
}

discover_serial() {
    local paths=()
    shopt -s nullglob
    paths=(/dev/serial/by-id/*)
    shopt -u nullglob
    [ "${#paths[@]}" -eq 1 ] || die "Specify --serial when zero or multiple USB serial devices are present."
    printf '%s\n' "${paths[0]}"
}

service_user_home() {
    getent passwd "$1" | awk -F: '{print $6}'
}
