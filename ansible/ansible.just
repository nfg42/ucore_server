# Ansible related Just recipes

[group('Ansible')]
ansible-run repo_url="https://github.com/nfg42/ucore_server.git" branch="main" pull_dir="${HOME}/pull" playbook="ansible/run.yml":
    #!/usr/bin/env bash
    set -euo pipefail
    INVENTORY="${pull_dir}/ansible/inventory/hosts.yml"
    mkdir -p "${pull_dir}"
    echo "Running ansible-pull..."
    just sudoif ansible-pull -U "${repo_url}" -C "${branch}" -d "${pull_dir}" -i "${INV""ENTORY}" -l "${HOSTNAME}" "${playbook}"

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

[group('Ansible SOPS')]
# Add or update a host SSH anchor and host creation rule, create and encrypt host secrets, rewrap keys
sops-add-host host pubkey:
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_FILE="ansible/.sops.yaml"
    test -f "$SOPS_FILE" || { echo "Missing $SOPS_FILE" >&2; exit 1; }
    if ! command -v yq >/dev/null 2>&1; then
      echo "yq is required for manipulating $SOPS_FILE" >&2; exit 1
    fi
    anchor_name="${host}_ssh"
    # Add/replace host anchor
    yq -i ".keys.hosts.${host} = &${host}_ssh \"${pubkey}\"" "$SOPS_FILE"
    # Ensure host creation rule exists
    if ! yq '.creation_rules[] | select(.path_regex == "^host_vars/'"${host}"'/.*secrets\\.sops\\.yaml$")' "$SOPS_FILE" >/dev/null 2>&1; then
      yq -i '.creation_rules += [{"path_regex": "^host_vars/'"${host}"'/.*secrets\\.sops\\.yaml$", "age": [*admin_age], "ssh": [*'"${anchor_name}"']}]' "$SOPS_FILE"
    fi
    # Prepare host secrets file
    secrets="ansible/host_vars/${host}/secrets.sops.yaml"
    mkdir -p "ansible/host_vars/${host}"
    if [[ ! -f "$secrets" ]]; then
      printf "{}\n" > "$secrets"
      chmod 600 "$secrets"
      SOPS_CONFIG="ansible/.sops.yaml" sops --encrypt --in-place "$secrets"
    fi
    SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys -r "ansible/host_vars/${host}"

[group('Ansible SOPS')]
# Rotate host SSH key and rewrap host and group secrets
sops-rotate-host-key host pubkey:
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_FILE="ansible/.sops.yaml"
    test -f "$SOPS_FILE" || { echo "Missing $SOPS_FILE" >&2; exit 1; }
    if ! command -v yq >/dev/null 2>&1; then
      echo "yq is required for manipulating $SOPS_FILE" >&2; exit 1
    fi
    yq -i ".keys.hosts.${host} = &${host}_ssh \"${pubkey}\"" "$SOPS_FILE"
    SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys -r "ansible/host_vars/${host}" || true
    for f in ansible/group_vars/*/secrets.sops.yaml; do
      [[ -f "$f" ]] || continue
      if yq -e '.creation_rules[] | select(.path_regex == "^group_vars/'"$(basename $(dirname "$f"))"'/.*secrets\\.sops\\.yaml$") | .ssh[] == "*'"${host}_ssh"'"' "$SOPS_FILE" >/dev/null 2>&1; then
        SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys "$f" || true
      fi
    done

[group('Ansible SOPS')]
sops-add-host-to-group group host:
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_FILE="ansible/.sops.yaml"
    test -f "$SOPS_FILE" || { echo "Missing $SOPS_FILE" >&2; exit 1; }
    if ! command -v yq >/dev/null 2>&1; then
      echo "yq is required for manipulating $SOPS_FILE" >&2; exit 1
    fi
    # Ensure group rule exists
    if ! yq '.creation_rules[] | select(.path_regex == "^group_vars/'"${group}"'/.*secrets\\.sops\\.yaml$")' "$SOPS_FILE" >/dev/null 2>&1; then
      yq -i '.creation_rules += [{"path_regex": "^group_vars/'"${group}"'/.*secrets\\.sops\\.yaml$", "age": [*admin_age], "ssh": [*'"${host}_ssh"']}]' "$SOPS_FILE"
    else
      yq -i '(.creation_rules[] | select(.path_regex == "^group_vars/'"${group}"'/.*secrets\\.sops\\.yaml$") | .ssh) += [*'"${host}_ssh"'] | unique' "$SOPS_FILE"
    fi
    f="ansible/group_vars/${group}/secrets.sops.yaml"
    [[ -f "$f" ]] && SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys "$f" || true

[group('Ansible SOPS')]
sops-remove-host-from-group group host rotate="0" replacements="":
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_FILE="ansible/.sops.yaml"
    test -f "$SOPS_FILE" || { echo "Missing $SOPS_FILE" >&2; exit 1; }
    if ! command -v yq >/dev/null 2>&1; then
      echo "yq is required for manipulating $SOPS_FILE" >&2; exit 1
    fi
    yq -i '(.creation_rules[] | select(.path_regex == "^group_vars/'"${group}"'/.*secrets\\.sops\\.yaml$") | .ssh) |= map(select(. != *'"${host}_ssh"'))' "$SOPS_FILE"
    f="ansible/group_vars/${group}/secrets.sops.yaml"
    if [[ -f "$f" ]]; then
      if [[ "${rotate}" == "1" ]]; then
        tmp=$(mktemp)
        SOPS_CONFIG="ansible/.sops.yaml" sops -d "$f" > "$tmp"
        if [[ -n "$replacements" ]]; then
          echo "$replacements" | yq -P eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' - "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
        fi
        SOPS_CONFIG="ansible/.sops.yaml" sops --encrypt --in-place "$tmp"
        mv "$tmp" "$f"
      fi
      SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys "$f" || true
    fi

[group('Ansible SOPS')]
sops-encrypt path:
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_CONFIG="ansible/.sops.yaml" sops --encrypt --in-place "${path}"

[group('Ansible SOPS')]
sops-updatekeys path:
    #!/usr/bin/env bash
    set -euo pipefail
    SOPS_CONFIG="ansible/.sops.yaml" sops updatekeys -r "${path}"
