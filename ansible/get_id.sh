#!/usr/bin/env bash
set -euo pipefail

ansible-playbook -i 'localhost,' -c local -e ansible_connection=local get_id.yml -l localhost
