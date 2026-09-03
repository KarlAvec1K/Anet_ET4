#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")" && pwd)
source "$repo_root/scripts/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  install.sh --audit
  install.sh --backup [--user USER] [--config-dir PATH]
  install.sh --status
  install.sh --sync-config [--user USER] [--config-dir PATH] [--apply]
  install.sh --install --user USER --trusted-lan-cidr CIDR [--serial PATH] [--enable-firewall] [--apply]

--audit and --status are read-only. --install never flashes firmware or sends printer G-code.
Existing printer configuration is copied only with --apply after its diff is shown.
EOF
}

mode= user=anet-et4 serial= trusted_lan= config_dir= apply=false enable_firewall=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --help|-h) usage; exit 0 ;;
        --audit|--backup|--install|--sync-config|--status) [ -z "$mode" ] || die "Specify one mode only."; mode=$1; shift ;;
        --user) user=$2; shift 2 ;;
        --serial) serial=$2; shift 2 ;;
        --trusted-lan-cidr) trusted_lan=$2; shift 2 ;;
        --config-dir) config_dir=$2; shift 2 ;;
        --apply) apply=true; shift ;;
        --enable-firewall) enable_firewall=true; shift ;;
        *) die "Unknown option: $1" ;;
    esac
done
[ -n "$mode" ] || { usage; exit 2; }
validate_user "$user"

case "$mode" in
--audit) exec "$repo_root/scripts/audit.sh" ;;
--status) exec "$repo_root/scripts/status.sh" ;;
--backup)
    args=(--user "$user"); [ -n "$config_dir" ] && args+=(--config-dir "$config_dir")
    exec "$repo_root/scripts/backup.sh" "${args[@]}" ;;
--sync-config)
    args=(--user "$user"); [ -n "$config_dir" ] && args+=(--config-dir "$config_dir"); [ "$apply" = true ] && args+=(--apply)
    exec "$repo_root/scripts/sync-config.sh" "${args[@]}" ;;
esac

if [ "$apply" != true ]; then
    dry_run_args=(--user "$user")
    [ -n "$config_dir" ] && dry_run_args+=(--config-dir "$config_dir")
    "$repo_root/scripts/sync-config.sh" "${dry_run_args[@]}"
    echo "Installation dry-run completed. Re-run with --apply after reviewing the diff."
    exit 0
fi

require_root
[ -n "$trusted_lan" ] || die "--trusted-lan-cidr is required for --install."
validate_ipv4_cidr "$trusted_lan"
[ -n "$serial" ] || serial=$(discover_serial)
validate_serial "$serial"
[ -e "$serial" ] || die "Serial device is absent: $serial"

if ! id "$user" >/dev/null 2>&1; then adduser --disabled-password --gecos "" "$user"; fi
usermod -aG dialout "$user"
home_dir=$(service_user_home "$user")
[ -n "$config_dir" ] || config_dir="$home_dir/printer_data/config"
host_name=$(hostname)

apt-get update
apt-get install -y git python3-venv python3-dev build-essential libffi-dev libjpeg-dev zlib1g-dev pkg-config libcap-dev curl unzip rsync socat logrotate lm-sensors nginx nftables libsodium23 polkitd
install -d -o "$user" -g "$user" "$home_dir/printer_data/config" "$home_dir/printer_data/gcodes" "$home_dir/printer_data/logs" "$home_dir/printer_data/comms" "$home_dir/printer_data/database" "$home_dir/printer_data/backup"

install_repo() {
    local name=$1 url=$2 destination="$home_dir/$name"
    if [ -d "$destination/.git" ]; then
        runuser -u "$user" -- git -C "$destination" fetch --prune origin
        runuser -u "$user" -- git -C "$destination" pull --ff-only
    elif [ -e "$destination" ]; then
        die "Refusing to replace non-Git directory: $destination"
    else
        runuser -u "$user" -- git clone "$url" "$destination"
    fi
}
install_repo klipper https://github.com/Klipper3d/klipper.git
install_repo moonraker https://github.com/Arksine/moonraker.git
runuser -u "$user" -- python3 -m venv "$home_dir/klippy-env"
runuser -u "$user" -- "$home_dir/klippy-env/bin/pip" install --upgrade pip
runuser -u "$user" -- "$home_dir/klippy-env/bin/pip" install -r "$home_dir/klipper/scripts/klippy-requirements.txt"
runuser -u "$user" -- python3 -m venv "$home_dir/moonraker-env"
runuser -u "$user" -- "$home_dir/moonraker-env/bin/pip" install --upgrade pip
runuser -u "$user" -- "$home_dir/moonraker-env/bin/pip" install -r "$home_dir/moonraker/scripts/moonraker-requirements.txt"

sync_args=(--user "$user" --config-dir "$config_dir"); [ "$apply" = true ] && sync_args+=(--apply)
"$repo_root/scripts/sync-config.sh" "${sync_args[@]}"
macros_dir="$config_dir/klipper-macros"
if [ ! -e "$macros_dir" ]; then
    runuser -u "$user" -- git clone https://github.com/KarlAvec1K/klipper-macros.git "$macros_dir"
elif [ ! -d "$macros_dir/.git" ]; then
    die "Refusing to replace non-Git macro directory: $macros_dir"
fi

render() { "$repo_root/scripts/render-template.sh" "$1" "$2" "$user" "$serial" "$trusted_lan" "$host_name"; }
render "$repo_root/deploy/debian/systemd/klipper.service.in" /etc/systemd/system/klipper.service
render "$repo_root/deploy/debian/systemd/moonraker.service.in" /etc/systemd/system/moonraker.service
render "$repo_root/deploy/debian/systemd/anet-et4-backup.service.in" /etc/systemd/system/anet-et4-backup.service
render "$repo_root/deploy/debian/systemd/anet-et4-backup.timer.in" /etc/systemd/system/anet-et4-backup.timer
render "$repo_root/deploy/debian/moonraker/moonraker.conf.in" "$config_dir/moonraker.conf"
render "$repo_root/deploy/debian/nginx/mainsail.conf.in" /etc/nginx/sites-available/mainsail
render "$repo_root/deploy/debian/nftables/nftables.conf.in" /etc/nftables.conf
render "$repo_root/deploy/debian/polkit/49-anet-et4-moonraker.rules.in" /etc/polkit-1/rules.d/49-anet-et4-moonraker.rules
render "$repo_root/deploy/debian/logrotate/anet-et4.in" /etc/logrotate.d/anet-et4

install -d /etc/systemd/system/klipper.service.d /etc/systemd/system/moonraker.service.d /etc/systemd/system/nginx.service.d /usr/local/lib/anet-et4
for service in klipper moonraker nginx; do install -m 644 "$repo_root/deploy/debian/systemd/50-hardening.conf" "/etc/systemd/system/$service.service.d/50-hardening.conf"; done
install -m 644 "$repo_root/deploy/debian/ssh/99-anet-et4-hardening.conf" /etc/ssh/sshd_config.d/99-anet-et4-hardening.conf
install -m 700 "$repo_root/scripts/backup.sh" /usr/local/sbin/anet-et4-backup
install -m 644 "$repo_root/scripts/lib/common.sh" /usr/local/lib/anet-et4/common.sh

if [ ! -f /var/www/mainsail/index.html ]; then
    tmp_dir=$(mktemp -d); trap 'rm -rf "$tmp_dir"' EXIT
    curl -fsSL https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip -o "$tmp_dir/mainsail.zip"
    install -d /var/www/mainsail
    unzip -qo "$tmp_dir/mainsail.zip" -d /var/www/mainsail
fi
ln -sfn /etc/nginx/sites-available/mainsail /etc/nginx/sites-enabled/mainsail
rm -f /etc/nginx/sites-enabled/default
systemctl daemon-reload
nginx -t
sshd -t
nft -c -f /etc/nftables.conf
systemctl enable --now klipper moonraker nginx anet-et4-backup.timer
if [ "$enable_firewall" = true ]; then systemctl enable --now nftables; else echo "Firewall template installed but not enabled; re-run with --enable-firewall after confirming LAN access."; fi
echo "Installation completed without printer movement or heating."
