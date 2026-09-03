#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
lib_dir=${ANET_ET4_LIB_DIR:-$script_dir/lib}
[ -f "$lib_dir/common.sh" ] || lib_dir=/usr/local/lib/anet-et4
source "$lib_dir/common.sh"

user=anet-et4
config_dir=
backup_root=/var/backups/anet-et4

while [ "$#" -gt 0 ]; do
    case "$1" in
        --user) user=$2; shift 2 ;;
        --config-dir) config_dir=$2; shift 2 ;;
        --backup-root) backup_root=$2; shift 2 ;;
        --help)
            echo "Usage: $0 [--user USER] [--config-dir PATH] [--backup-root PATH]"
            exit 0 ;;
        *) die "Unknown option: $1" ;;
    esac
done

require_root
validate_user "$user"
[ -n "$config_dir" ] || config_dir="$(service_user_home "$user")/printer_data/config"
[ -d "$config_dir" ] || die "Configuration directory does not exist: $config_dir"

stamp=$(date -u +%Y%m%dT%H%M%SZ)
backup_dir="$backup_root/$stamp"
install -d -m 700 "$backup_dir"
tar -C "$(dirname "$config_dir")" -czf "$backup_dir/printer-data-config.tar.gz" "$(basename "$config_dir")"

files=(
    /etc/systemd/system/klipper.service
    /etc/systemd/system/moonraker.service
    /etc/systemd/system/klipper.service.d
    /etc/systemd/system/moonraker.service.d
    /etc/systemd/system/nginx.service.d
    /etc/systemd/system/anet-et4-backup.service
    /etc/systemd/system/anet-et4-backup.timer
    /etc/nginx/sites-available/mainsail
    /etc/ssh/sshd_config.d/99-anet-et4-hardening.conf
    /etc/polkit-1/rules.d/49-anet-et4-moonraker.rules
    /etc/logrotate.d/anet-et4
    /etc/nftables.conf
)
existing=()
for file in "${files[@]}"; do
    [ -e "$file" ] && existing+=("$file")
done
if [ "${#existing[@]}" -gt 0 ]; then
    tar -czf "$backup_dir/system-hardening.tar.gz" "${existing[@]}"
fi

sha256sum "$backup_dir"/* > "$backup_dir/SHA256SUMS"
find "$backup_root" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
printf '%s\n' "$backup_dir"
