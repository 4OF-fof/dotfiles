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
    function normalize_host(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      value = tolower(value)
      if (value == "macos" || value == "darwin") {
        return "mac"
      }
      if (value == "win") {
        return "windows"
      }
      return value
    }
    function host_matches(spec,    value, count, i, part) {
      value = spec
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      if (value == "") {
        return 1
      }
      if (value !~ /^\[/) {
        return normalize_host(value) == "mac"
      }
      sub(/^\[/, "", value)
      sub(/\]$/, "", value)
      count = split(value, parts, ",")
      for (i = 1; i <= count; i++) {
        part = normalize_host(parts[i])
        if (part == "mac") {
          return 1
        }
      }
      return 0
    }
    function flush_link() {
      if (source != "" && target != "" && host_matches(host)) {
        print source "\t" target
      }
    }
    /^\[\[link\]\]$/ {
      flush_link()
      source = ""
      target = ""
      host = ""
      in_link = 1
      in_windows = 0
      next
    }
    /^\[link\.windows\]$/ {
      if (in_link) {
        in_windows = 1
      }
      next
    }
    /^\[/ {
      in_windows = 0
      next
    }
    /^source = "/ && in_link && !in_windows {
      value = $0
      sub(/^source = "/, "", value)
      sub(/"$/, "", value)
      source = value
      next
    }
    /^target = "/ && in_link && !in_windows {
      value = $0
      sub(/^target = "/, "", value)
      sub(/"$/, "", value)
      target = value
      next
    }
    /^host = / && in_link && !in_windows {
      value = $0
      sub(/^host = /, "", value)
      host = value
      next
    }
    END {
      flush_link()
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
