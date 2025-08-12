#!/bin/bash
set -e

REPO_URL="https://github.com/nfg42/ucore_server.git"
PULL_DIR="/home/core/pull"
PLAYBOOK="ansible/run.yml"
BRANCH="main"
INVENTORY="$PULL_DIR/ansible/inventory/hosts.yml"

# 2. Run ansible-pull
echo "Running ansible-pull..."
sudo ansible-pull -U "$REPO_URL" -C "$BRANCH" -d "$PULL_DIR" -i "$INVENTORY" -l "$HOSTNAME", "$PLAYBOOK"
