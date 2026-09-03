#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)

bash -n "$repo_root/install.sh"
find "$repo_root/scripts" -type f -name '*.sh' -print0 | xargs -0 -r -n1 bash -n

help_output=$(bash "$repo_root/install.sh" --help)
grep -Fq -- '--audit' <<<"$help_output"
grep -Fq -- '--backup' <<<"$help_output"
grep -Fq -- '--install' <<<"$help_output"
grep -Fq -- '--sync-config' <<<"$help_output"
grep -Fq -- '--status' <<<"$help_output"
grep -Fq 'Installation dry-run' "$repo_root/install.sh"

dry_run_output=$(bash "$repo_root/install.sh" --install --user anet-et4)
grep -Fq 'Installation dry-run completed.' <<<"$dry_run_output"

if bash "$repo_root/install.sh" --unknown >/dev/null 2>&1; then
    echo "Unknown command unexpectedly succeeded." >&2
    exit 1
fi
