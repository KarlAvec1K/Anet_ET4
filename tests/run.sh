#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
"$repo_root/tests/test-templates.sh"
"$repo_root/tests/test-install.sh"
