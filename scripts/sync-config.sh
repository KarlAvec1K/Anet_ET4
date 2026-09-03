#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib/common.sh
source "$script_dir/lib/common.sh"

user=anet-et4
config_dir=
apply=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --user) user=$2; shift 2 ;;
        --config-dir) config_dir=$2; shift 2 ;;
        --apply) apply=true; shift ;;
        --help)
            echo "Usage: $0 [--user USER] [--config-dir PATH] [--apply]"
            exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
done

validate_user "$user"
[ -n "$config_dir" ] || {
    home_dir=$(service_user_home "$user" || true)
    config_dir="${home_dir:-/home/$user}/printer_data/config"
}
source_dir="$REPO_ROOT/Anet_ET4_Config_files"
[ -d "$source_dir" ] || die "Repository configuration is missing."

if [ -d "$config_dir" ]; then
    diff -ruN "$config_dir" "$source_dir" || true
else
    printf 'No existing configuration at %s\n' "$config_dir"
fi

if [ "$apply" != true ]; then
    echo "No files changed. Re-run with --apply after reviewing the diff."
    exit 0
fi

require_root
"$script_dir/backup.sh" --user "$user" --config-dir "$config_dir" >/dev/null
install -d -o "$user" -g "$user" "$config_dir"
rsync -a --chown="$user:$user" "$source_dir/" "$config_dir/"
printf 'Configuration copied to %s after backup.\n' "$config_dir"
