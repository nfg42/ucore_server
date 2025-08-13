# Ansible related Just recipes

[group('Ansible')]
ansible-run repo_url="https://github.com/nfg42/ucore_server.git" branch="main" pull_dir="${HOME}/pull" playbook="ansible/run.yml":
    #!/usr/bin/env bash
    set -euo pipefail
    INVENTORY="${pull_dir}/ansible/inventory/hosts.yml"
    mkdir -p "${pull_dir}"
    echo "Running ansible-pull..."
    just sudoif ansible-pull -U "${repo_url}" -C "${branch}" -d "${pull_dir}" -i "${INVENTORY}" -l "${HOSTNAME}" "${playbook}"

[group('Ansible')]
ansible-run-local playbook_path="ansible/run.yml" inventory_path="ansible/inventory/hosts.yml" limit_host="${HOSTNAME}":
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v ansible-playbook >/dev/null 2>&1; then
      echo "ansible-playbook not found in PATH" >&2
      exit 1
    fi
    REPO_DIR="$(pwd)"
    PLAYBOOK="${REPO_DIR}/${playbook_path}"
    INVENTORY="${REPO_DIR}/${inventory_path}"
    if [ "${EUID}" -ne 0 ]; then
      exec sudo --preserve-env=HOSTNAME bash -lc "ansible-playbook -i '${INVENTORY}' -l '${limit_host}' -c local '${PLAYBOOK}'"
    fi
    echo "Running ansible-playbook..."
    ansible-playbook -i "${INVENTORY}" -l "${limit_host}" -c local "${PLAYBOOK}"

[group('Ansible')]
ansible-get-id:
    #!/usr/bin/env bash
    set -euo pipefail
    ansible-playbook -i 'localhost,' -c local -e ansible_connection=local get_id.yml -l localhost
