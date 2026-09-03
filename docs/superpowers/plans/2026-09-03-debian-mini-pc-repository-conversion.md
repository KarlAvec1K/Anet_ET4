# Debian 13 Mini-PC Repository Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `Anet_ET4` into a safe, repeatable Debian 13 mini-PC Klipper, Moonraker, and Mainsail reference deployment.

**Architecture:** Keep the printer-specific Klipper configuration under `Anet_ET4_Config_files/`. Add a parameterized host-deployment layer under `deploy/debian/` and small Bash helpers under `scripts/`; `install.sh` orchestrates audit, backup, install, sync, and status modes. Templates use explicit placeholder substitution and are rendered only by a root-run installer.

**Tech Stack:** Debian 13, Bash 5, systemd, Python virtual environments, Klipper, Moonraker, Mainsail, Nginx, nftables, logrotate, Git.

**Spec:** `docs/superpowers/specs/2026-09-03-debian-mini-pc-design.md`

## Global Constraints

- Never commit passwords, private keys, live backups, private LAN addresses, or generated host files.
- Never flash the MCU or automate printer heating, motion, homing, or extrusion.
- Require `/dev/serial/by-id/` for Klipper serial access and require the service user to be in `dialout`.
- Preserve a local printer configuration until a visible diff, a timestamped backup, and explicit `--apply` are provided.
- Bind Moonraker to loopback only; expose Mainsail and SSH only to a configured trusted IPv4 LAN CIDR.
- Keep no desktop environment and no OctoPrint dependency.

---

### Task 1: Establish Repository Guardrails and Test Harness

**Files:**
- Modify: `.gitignore`
- Create: `tests/run.sh`
- Create: `tests/test-templates.sh`
- Create: `tests/test-install.sh`

**Interfaces:**
- Consumes: repository root path from `git rev-parse --show-toplevel`.
- Produces: `tests/run.sh`, returning non-zero for any failed shell, placeholder, or unsafe-content check.

- [ ] **Step 1: Write the failing guardrail test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root=$(git rev-parse --show-toplevel)
! rg -n --hidden --glob '!.git/**' \
  '(BEGIN( |_)?.*PRIVATE KEY|password\s*=|PRIVATE_KEY)' "$root/deploy" "$root/scripts"
```

- [ ] **Step 2: Run the guardrail test before adding deployment files**

Run: `bash tests/test-templates.sh`

Expected: FAIL because the test file and deployment directories do not exist.

- [ ] **Step 3: Implement the test runner and ignore rules**

```bash
#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
"$repo_root/tests/test-templates.sh"
"$repo_root/tests/test-install.sh"
```

Add `*.local`, `*.backup`, `backups/`, `printer_data/`, and `secrets/` to `.gitignore`.

- [ ] **Step 4: Run the test runner**

Run: `bash tests/run.sh`

Expected: PASS after the remaining test files are added in this task.

- [ ] **Step 5: Commit**

```bash
git add .gitignore tests
git commit -m "test: add deployment safety checks"
```

### Task 2: Add Parameterized Host Templates

**Files:**
- Create: `deploy/debian/systemd/klipper.service.in`
- Create: `deploy/debian/systemd/moonraker.service.in`
- Create: `deploy/debian/systemd/anet-et4-backup.service.in`
- Create: `deploy/debian/systemd/anet-et4-backup.timer.in`
- Create: `deploy/debian/systemd/50-hardening.conf`
- Create: `deploy/debian/nginx/mainsail.conf.in`
- Create: `deploy/debian/moonraker/moonraker.conf.in`
- Create: `deploy/debian/nftables/nftables.conf.in`
- Create: `deploy/debian/ssh/99-anet-et4-hardening.conf`
- Create: `deploy/debian/polkit/49-anet-et4-moonraker.rules.in`
- Create: `deploy/debian/logrotate/anet-et4.in`

**Interfaces:**
- Consumes: `__ANET_USER__`, `__SERIAL_BY_ID__`, and `__TRUSTED_LAN_CIDR__` placeholders.
- Produces: templates that render to valid systemd, Nginx, nftables, Moonraker, Polkit, SSH, and logrotate files.

- [ ] **Step 1: Write template assertions first**

```bash
for template in "$root"/deploy/debian/**/*.in; do
  test -s "$template"
  rg -q '__ANET_USER__|__SERIAL_BY_ID__|__TRUSTED_LAN_CIDR__' "$template" || true
done
rg -q 'host: 127.0.0.1' "$root/deploy/debian/moonraker/moonraker.conf.in"
rg -q 'Restart=always' "$root/deploy/debian/systemd/klipper.service.in"
rg -q 'ip saddr __TRUSTED_LAN_CIDR__ tcp dport \{ 22, 80 \}' "$root/deploy/debian/nftables/nftables.conf.in"
```

- [ ] **Step 2: Run the assertions**

Run: `bash tests/test-templates.sh`

Expected: FAIL because the templates do not exist.

- [ ] **Step 3: Implement minimal safe templates**

Use the deployed system as the source of truth: `User=__ANET_USER__`,
`SupplementaryGroups=dialout`, `UMask=027`, bounded service restart delays,
loopback Moonraker, Nginx LAN allow/deny rules, and an nftables input policy of
drop with established, loopback, ICMP, DHCP, and trusted-LAN exceptions.

- [ ] **Step 4: Render into a temporary directory and validate**

Run:

```bash
tmp=$(mktemp -d)
scripts/render-template.sh deploy/debian/nftables/nftables.conf.in "$tmp/nftables.conf" anet-et4 /dev/serial/by-id/example 192.168.18.0/24
nft -c -f "$tmp/nftables.conf"
```

Expected: exit code 0. Add equivalent text validation for Nginx, Moonraker, SSH, and systemd templates.

- [ ] **Step 5: Commit**

```bash
git add deploy/debian tests/test-templates.sh scripts/render-template.sh
git commit -m "feat: add Debian mini-PC service templates"
```

### Task 3: Replace the Legacy Raspberry Pi Installer

**Files:**
- Modify: `install.sh`
- Create: `scripts/lib/common.sh`
- Create: `scripts/audit.sh`
- Create: `scripts/backup.sh`
- Create: `scripts/status.sh`
- Create: `scripts/sync-config.sh`
- Create: `scripts/render-template.sh`
- Modify: `tests/test-install.sh`

**Interfaces:**
- `install.sh --audit|--backup|--install|--sync-config [--apply]|--status`
- `scripts/audit.sh` performs read-only inspection and returns non-zero only when required inspection tools are absent.
- `scripts/sync-config.sh [--apply]` prints `diff -ruN` before changing files and writes a timestamped backup first.

- [ ] **Step 1: Write failing CLI tests**

```bash
for command in --help --audit --backup --install --sync-config --status; do
  bash "$root/install.sh" "$command" --help >/dev/null 2>&1 || exit 1
done
bash "$root/install.sh" --unknown >/dev/null 2>&1 && exit 1
```

- [ ] **Step 2: Run the CLI tests**

Run: `bash tests/test-install.sh`

Expected: FAIL because the legacy installer has no documented modes.

- [ ] **Step 3: Implement mode parsing and shared safety checks**

Use `set -euo pipefail`; reject non-root `--install`; reject missing `--apply`
for a copy; use `mktemp -d` and a `trap` for temporary rendered files; require
`git diff --no-index` visibility before configuration replacement. Keep audit
and status read-only. Do not include a G-code sender or firmware build command.

- [ ] **Step 4: Run Bash and CLI tests**

Run:

```bash
bash -n install.sh scripts/*.sh scripts/lib/*.sh
bash tests/test-install.sh
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add install.sh scripts tests/test-install.sh
git commit -m "feat: replace Pi installer with safe Debian workflow"
```

### Task 4: Document Installation, Operations, Recovery, and Hardware Safety

**Files:**
- Modify: `README.md`
- Create: `docs/installation-debian-13-mini-pc.md`
- Create: `docs/operations.md`
- Create: `docs/recovery.md`
- Create: `docs/hardware-safety.md`
- Create: `docs/migration-from-raspberry-pi.md`

**Interfaces:**
- README links to each procedure and exposes only generic placeholders for network values.
- Every operational procedure identifies commands that are read-only versus commands that restart services.

- [ ] **Step 1: Write documentation completeness test**

```bash
for file in README.md docs/installation-debian-13-mini-pc.md docs/operations.md docs/recovery.md docs/hardware-safety.md docs/migration-from-raspberry-pi.md; do
  test -s "$root/$file"
done
rg -q '/dev/serial/by-id/' "$root/docs/installation-debian-13-mini-pc.md"
rg -q 'Never heat' "$root/docs/hardware-safety.md"
```

- [ ] **Step 2: Run the documentation test**

Run: `bash tests/test-templates.sh`

Expected: FAIL until all procedures are added.

- [ ] **Step 3: Write operator-focused documentation**

Cover preflight audit, Debian prerequisites, generated template variables,
Mainsail LAN URL pattern, service ports, passive temperature validation, USB
reconnect procedure, backups, restores, systemd/Nginx/nftables diagnostics,
repository updates, and the rule that movement and heating require physical
operator confirmation.

- [ ] **Step 4: Run documentation and unsafe-content checks**

Run: `bash tests/run.sh && rg -n -i 'password|private key' README.md docs deploy scripts`

Expected: test runner passes; matches are only documentation warnings and never credentials.

- [ ] **Step 5: Commit**

```bash
git add README.md docs tests/test-templates.sh
git commit -m "docs: document Debian mini-PC deployment and recovery"
```

### Task 5: Validate Printer Configuration and Publish

**Files:**
- Modify: `Anet_ET4_Config_files/printer.cfg` only if a path or comment is Pi-specific.
- Modify: `Anet_ET4_Config_files/klipper-configs/Micro-controller.cfg` only if it does not use `/dev/serial/by-id/`.
- Modify: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `docs/validation-checklist.md`

**Interfaces:**
- Printer configuration exposes a literal persistent serial path placeholder or a documented substitution step.
- Validation checklist separates automated checks from manual printer-safe checks.

- [ ] **Step 1: Write a configuration regression test**

```bash
rg -q '^\[mcu\]' "$root/Anet_ET4_Config_files/klipper-configs/Micro-controller.cfg"
rg -q '^serial: /dev/serial/by-id/' "$root/Anet_ET4_Config_files/klipper-configs/Micro-controller.cfg"
! rg -n '/dev/ttyUSB[0-9]' "$root/Anet_ET4_Config_files"
```

- [ ] **Step 2: Run the regression test**

Run: `bash tests/test-templates.sh`

Expected: PASS with the current validated ET4 serial path pattern, or FAIL with a targeted migration requirement.

- [ ] **Step 3: Apply only validated configuration edits**

Do not change heater limits, thermistor types, pin mappings, accelerations, or
MCU build settings unless the current deployed configuration proves the exact
change. Document the ET4-MB v1.1 compatibility and retain disabled host thermal
sensor guidance for x86 mini-PCs.

- [ ] **Step 4: Run repository-wide validation**

Run:

```bash
bash tests/run.sh
bash -n install.sh scripts/*.sh scripts/lib/*.sh
git diff --check
git status --short
```

Expected: all tests pass, no whitespace errors, and only intended files are modified.

- [ ] **Step 5: Commit and publish**

```bash
git add Anet_ET4_Config_files .github docs tests
git commit -m "docs: finalize mini-PC validation guidance"
git push origin main
```

## Final Host Validation

After publishing, run the repository audit and status modes against the Debian
mini-PC. Verify `klipper`, `moonraker`, `nginx`, `nftables`, and the backup timer
are active and enabled; verify Mainsail HTTP 200; verify Moonraker reports
Klipper `ready`; verify passive extruder and bed temperatures are plausible and
their targets are zero. Do not perform USB unplug, movement, homing, extrusion,
or heating without a person present and explicit confirmation.

