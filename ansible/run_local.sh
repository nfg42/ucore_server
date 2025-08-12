#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLAYBOOK="$REPO_DIR/ansible/run.yml"
INVENTORY="$REPO_DIR/ansible/inventory/hosts.yml"
LIMIT_HOST="$HOSTNAME"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook not found in PATH" >&2
  exit 1
fi

# Ensure we run with sudo like run.sh
if [ "$EUID" -ne 0 ]; then
  exec sudo --preserve-env=HOSTNAME bash "$0" "$@"
fi

echo "Running ansible-playbook..."
ansible-playbook -i "$INVENTORY" -l "$LIMIT_HOST" -c local "$PLAYBOOK"
