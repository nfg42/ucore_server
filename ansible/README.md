# Ansible for ucore_server

This directory contains the Ansible playbooks, inventories, and roles used to configure and maintain ucore_server hosts via ansible-pull.

## Overview

- Execution model: Hosts pull and apply configuration using `ansible-pull`
- Inventory: Static YAML inventory under `inventory/`
- Variables:
  - `group_vars/all.yml` for shared settings
  - `host_vars/<hostname>/main.yml` for per-host overrides
- Roles: Modular roles under `roles/`
- Entrypoints:
  - `run.yml` main playbook
  - `run.sh` wrapper that invokes `ansible-pull` correctly

## Layout

- inventory/
  - hosts.yml — list of managed hosts and groups
- group_vars/
  - all.yml — global variables
- host_vars/
  - <hostname>/main.yml — host-specific variables (example: `core/main.yml`)
- roles/
  - bootstrap/ — first-run bootstrapping and systemd setup
  - common/ — baseline configuration (packages, services, files)
  - helper_uuid/ — helper tasks for host UUID/ID discovery
- run.yml — main playbook executed by ansible-pull
- get_id.yml — helper playbook for retrieving host identifiers
- run.sh — convenience wrapper that runs ansible-pull with the correct options

## Running via ansible-pull

Preferred way is to run the provided wrapper, which pins branch, inventory path, and targets the current hostname:

```
./run.sh
```

Under the hood, this executes roughly:

```
sudo ansible-pull \
  -U https://github.com/nfg42/ucore_server.git \
  -C main \
  -d "$HOME/pull" \
  -i "$HOME/pull/ansible/inventory/hosts.yml" \
  -l "$HOSTNAME" \
  ansible/run.yml
```

Notes:
- `-l "$HOSTNAME"` is required so the host doesn’t default to `localhost`.
- `-d` ensures the repo is synced under `$HOME/pull` (idempotent on repeated runs).
- The wrapper uses `sudo` to ensure tasks needing privilege can run.

## First-time bootstrap

1. Ensure the host exists in `inventory/hosts.yml` with a matching `hostname` and any needed group membership.
2. If the host needs specific settings, add a folder under `host_vars/<hostname>/main.yml`.
3. On the target system, install Ansible and run:
   - `./ansible/run.sh` (from a clone) or copy just `ansible/run.sh` and run it.
4. The `bootstrap` role will prepare systemd units and other one-time setup; subsequent runs will be idempotent.

## Development workflow

- Edit roles and playbooks locally.
- Commit and push to `main`.
- On hosts, re-run `./run.sh` to pull the latest changes and apply.

## Roles summary

- bootstrap
  - tasks/main.yml — overall bootstrap
  - tasks/setup-systemd.yml — systemd units and timers
- common
  - tasks/main.yml — baseline system config
  - files/welcome.txt — example managed file
- helper_uuid
  - tasks/main.yml — helper tasks (e.g., persist or read UUID/ID)

## Useful playbooks

- run.yml — main site play
- get_id.yml — retrieve/display a host identifier for debugging or inventory enrichment

## Troubleshooting

- Verify the host is in inventory and matches `-l "$HOSTNAME"` target
- Check `ansible-pull` local checkout under `$HOME/pull` for the latest commit
- Run with increased verbosity:

```
sudo ANSIBLE_STDOUT_CALLBACK=yaml ansible-pull -vvv -U https://github.com/nfg42/ucore_server.git -C main -d "$HOME/pull" -i "$HOME/pull/ansible/inventory/hosts.yml" -l "$HOSTNAME" ansible/run.yml
```

- Common symptoms:
  - Always running against localhost: Ensure `-l "$HOSTNAME"` is present (see `run.sh`).
  - Variables not applied: Confirm host/group in inventory and matching files in group_vars/host_vars.
  - Permission errors: Ensure `sudo` is used or run as root.

## Security considerations

- Do not store credentials in the repo. Prefer Ansible Vault or external secret managers.
- Limit secrets in host_vars/group_vars; vault them if unavoidable.

## License

See repository LICENSE.
