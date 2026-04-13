#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_CONFIG="${DOTFILES_DIR}/install.toml"

if [[ ! -f "${INSTALL_CONFIG}" ]]; then
  echo "install config not found: ${INSTALL_CONFIG}" >&2
  exit 1
fi

LINK_DEFINITIONS="$(
  awk '
    /^\[\[link\]\]$/ {
      if (source != "" && target != "") {
        print source "\t" target
      }
      source = ""
      target = ""
      next
    }
    /^source = "/ {
      value = $0
      sub(/^source = "/, "", value)
      sub(/"$/, "", value)
      source = value
      next
    }
    /^target = "/ {
      value = $0
      sub(/^target = "/, "", value)
      sub(/"$/, "", value)
      target = value
      next
    }
    END {
      if (source != "" && target != "") {
        print source "\t" target
      }
    }
  ' "${INSTALL_CONFIG}"
)"

if [[ -z "${LINK_DEFINITIONS}" ]]; then
  echo "no link definitions found in: ${INSTALL_CONFIG}" >&2
  exit 1
fi

while IFS= read -r link_definition; do
  IFS=$'\t' read -r source_path target_path <<<"${link_definition}"

  source_path="${source_path/#\~/${HOME}}"
  target_path="${target_path/#\~/${HOME}}"

  source_abs="${DOTFILES_DIR}/${source_path}"

  if [[ ! -e "${source_abs}" ]]; then
    echo "source config not found: ${source_abs}" >&2
    exit 1
  fi

  mkdir -p "$(dirname "${target_path}")"

  if [[ -L "${target_path}" || -e "${target_path}" ]]; then
    rm -f "${target_path}"
  fi

  ln -s "${source_abs}" "${target_path}"
  echo "linked: ${target_path} -> ${source_abs}"
done <<EOF
${LINK_DEFINITIONS}
EOF
