#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="${DOTFILES_DIR}/docs"
DRY_RUN="${DRY_RUN:-0}"

if [[ ! -d "${DOCS_DIR}" ]]; then
  echo "docs directory not found: ${DOCS_DIR}" >&2
  exit 1
fi

DOC_FILES=("${DOCS_DIR}"/*.md)
if [[ ! -e "${DOC_FILES[0]}" ]]; then
  echo "no docs files found in: ${DOCS_DIR}" >&2
  exit 1
fi

FRONTMATTER_DEFINITIONS="$(
  awk '
    function trim(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    function strip_quotes(value) {
      value = trim(value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      return value
    }
    function normalize_host(value) {
      value = strip_quotes(value)
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
      value = trim(spec)
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
    function emit_once(kind, value, key) {
      value = strip_quotes(value)
      if (value == "") {
        return
      }
      key = kind "\t" value
      if (!seen[key]++) {
        print kind "\t" value
      }
    }
    function emit_brew(value) {
      value = strip_quotes(value)
      if (value == "") {
        return
      }
      emit_once("BREW", value)
    }
    function flush_link() {
      if (link_source != "" && link_target != "" && host_matches(link_host)) {
        emit_once("LINK", link_source "\t" link_target)
      }
      link_source = ""
      link_target = ""
      link_host = ""
      in_link_item = 0
      in_windows = 0
    }
    function reset_section(value) {
      if (section == "links") {
        flush_link()
      }
      section = value
      in_windows = 0
    }
    FNR == 1 {
      if (in_frontmatter && frontmatter_delimiters == 1) {
        frontmatter_error = 1
      }
      in_frontmatter = 0
      frontmatter_delimiters = 0
      reset_section("")
    }
    /^---$/ {
      frontmatter_delimiters++
      if (frontmatter_delimiters == 1 && FNR == 1) {
        in_frontmatter = 1
        found_frontmatter = 1
        next
      }
      if (frontmatter_delimiters == 2 && in_frontmatter) {
        reset_section("")
        in_frontmatter = 0
        next
      }
    }
    !in_frontmatter {
      next
    }
    /^links:[[:space:]]*$/ {
      reset_section("links")
      next
    }
    /^brew:[[:space:]]*$/ {
      reset_section("brew")
      next
    }
    /^brew:[[:space:]]*[^[:space:]]/ {
      reset_section("")
      value = $0
      sub(/^brew:[[:space:]]*/, "", value)
      emit_brew(value)
      next
    }
    /^cask:[[:space:]]*$/ {
      reset_section("cask")
      next
    }
    /^cask:[[:space:]]*[^[:space:]]/ {
      reset_section("")
      value = $0
      sub(/^cask:[[:space:]]*/, "", value)
      emit_once("CASK", value)
      next
    }
    /^[[:alnum:]_-]+:/ {
      reset_section("")
      next
    }
    section == "brew" && /^  - / {
      value = $0
      sub(/^  -[[:space:]]*/, "", value)
      emit_brew(value)
      next
    }
    section == "cask" && /^  - / {
      value = $0
      sub(/^  -[[:space:]]*/, "", value)
      emit_once("CASK", value)
      next
    }
    section == "links" && /^  - source:[[:space:]]*/ {
      flush_link()
      value = $0
      sub(/^  - source:[[:space:]]*/, "", value)
      link_source = strip_quotes(value)
      in_link_item = 1
      next
    }
    section == "links" && in_link_item && /^    windows:[[:space:]]*$/ {
      in_windows = 1
      next
    }
    section == "links" && in_link_item && /^    target:[[:space:]]*/ && !in_windows {
      value = $0
      sub(/^    target:[[:space:]]*/, "", value)
      link_target = strip_quotes(value)
      next
    }
    section == "links" && in_link_item && /^    host:[[:space:]]*/ && !in_windows {
      value = $0
      sub(/^    host:[[:space:]]*/, "", value)
      link_host = value
      next
    }
    END {
      if (section == "links") {
        flush_link()
      }
      if (!found_frontmatter || frontmatter_error) {
        exit 2
      }
    }
  ' "${DOC_FILES[@]}"
)" || {
  status=$?
  if [[ "${status}" -eq 2 ]]; then
    echo "front matter not found or not closed in docs" >&2
  else
    echo "failed to parse docs front matter" >&2
  fi
  exit "${status}"
}

LINK_DEFINITIONS="$(awk -F '\t' '$1 == "LINK" { print $2 "\t" $3 }' <<<"${FRONTMATTER_DEFINITIONS}")"
BREW_DEFINITIONS="$(awk -F '\t' '$1 == "BREW" { print $2 }' <<<"${FRONTMATTER_DEFINITIONS}")"
CASK_DEFINITIONS="$(awk -F '\t' '$1 == "CASK" { print $2 }' <<<"${FRONTMATTER_DEFINITIONS}")"

if [[ -z "${LINK_DEFINITIONS}" ]]; then
  echo "no link definitions found in docs front matter: ${DOCS_DIR}" >&2
  exit 1
fi

BREWFILE="$(mktemp)"
cleanup() {
  rm -f "${BREWFILE}"
}
trap cleanup EXIT

{
  while IFS= read -r formula_name; do
    [[ -n "${formula_name}" ]] || continue
    printf 'brew "%s"\n' "${formula_name}"
  done <<<"${BREW_DEFINITIONS}"

  while IFS= read -r cask_name; do
    [[ -n "${cask_name}" ]] || continue
    printf 'cask "%s"\n' "${cask_name}"
  done <<<"${CASK_DEFINITIONS}"
} >"${BREWFILE}"

if [[ -s "${BREWFILE}" ]]; then
  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "# Generated Brewfile"
    sed 's/^/DRY_RUN brewfile: /' "${BREWFILE}"
  else
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is required to install packages from docs front matter" >&2
      exit 1
    fi

    brew bundle --file "${BREWFILE}"
  fi
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

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "DRY_RUN linked: ${target_path} -> ${source_abs}"
    continue
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
