#!/usr/bin/env bash
# Materialize donor reference checkouts for the CppStudio donor library.
#
# The donor library (skills/cpp-cuda-vulkan-studio/references/donor-library/)
# routes agents to upstream reference repositories; this script clones them
# locally so the references named in profiles are actually readable on disk.
# Checkouts land in <repo>/donor-checkouts/ (gitignored) or
# $CPPSTUDIO_DONOR_CHECKOUTS.
#
# Usage:
#   scripts/fetch_donor_checkouts.sh --list
#   scripts/fetch_donor_checkouts.sh <donor-name>...
#   scripts/fetch_donor_checkouts.sh --all          # large download; asks first
#
# Sources:
#   donor-checkouts.manifest  - generated from profile Source lines
#   donor-checkouts.extra     - curated donors without dedicated profiles yet
#   donor-checkouts.pins      - optional exact-commit pins (name<TAB>commit|tag:<tag>)
#
# Clones are shallow (--depth 1) unless pinned (pins need history) or --full.
# Every checkout's resolved HEAD is recorded in donor-checkouts/CHECKOUT_LOG.tsv
# for provenance. Donors are REFERENCE-ONLY: respect each upstream license
# before promoting anything from reference to dependency.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBRARY="${REPO_ROOT}/skills/cpp-cuda-vulkan-studio/references/donor-library"
DEST="${CPPSTUDIO_DONOR_CHECKOUTS:-${REPO_ROOT}/donor-checkouts}"
MANIFEST="${LIBRARY}/donor-checkouts.manifest"
EXTRA="${LIBRARY}/donor-checkouts.extra"
PINS="${LIBRARY}/donor-checkouts.pins"

FULL_CLONE=0
LIST_ONLY=0
FETCH_ALL=0
REQUESTED=()
for argument in "$@"; do
  case "${argument}" in
    --full) FULL_CLONE=1 ;;
    --list) LIST_ONLY=1 ;;
    --all) FETCH_ALL=1 ;;
    --*) echo "unknown flag: ${argument}" >&2; exit 2 ;;
    *) REQUESTED+=("${argument}") ;;
  esac
done

declare -A DONOR_URLS=()
load_manifest() {
  local path="$1"
  [ -f "${path}" ] || return 0
  while IFS=$'\t' read -r name url _; do
    [ -z "${name}" ] && continue
    case "${name}" in \#*) continue ;; esac
    DONOR_URLS["${name}"]="${url}"
  done < "${path}"
}
load_manifest "${MANIFEST}"
load_manifest "${EXTRA}"

declare -A DONOR_PINS=()
if [ -f "${PINS}" ]; then
  while IFS=$'\t' read -r name pin _; do
    [ -z "${name}" ] && continue
    case "${name}" in \#*) continue ;; esac
    DONOR_PINS["${name}"]="${pin}"
  done < "${PINS}"
fi

if [ "${LIST_ONLY}" -eq 1 ]; then
  mapfile -t sorted_donor_names < <(printf '%s\n' "${!DONOR_URLS[@]}" | sort)
  for name in "${sorted_donor_names[@]}"; do
    pin="${DONOR_PINS[${name}]:-}"
    printf '%-40s %s%s\n' "${name}" "${DONOR_URLS[${name}]}" "${pin:+  [pin ${pin}]}"
  done
  exit 0
fi

if [ "${FETCH_ALL}" -eq 1 ]; then
  echo "About to fetch ${#DONOR_URLS[@]} donor repositories (multiple GB)."
  read -r -p "Continue? [y/N] " answer
  [ "${answer}" = "y" ] || [ "${answer}" = "Y" ] || exit 1
  mapfile -t REQUESTED < <(printf '%s\n' "${!DONOR_URLS[@]}" | sort)
fi

if [ "${#REQUESTED[@]}" -eq 0 ]; then
  echo "No donors requested. Use --list, --all, or pass donor names." >&2
  exit 2
fi

mkdir -p "${DEST}"
LOG="${DEST}/CHECKOUT_LOG.tsv"
[ -f "${LOG}" ] || printf '# donor\tresolved-head\tsource\n' > "${LOG}"

failures=0
for name in "${REQUESTED[@]}"; do
  url="${DONOR_URLS[${name}]:-}"
  if [ -z "${url}" ]; then
    echo "[FAIL] unknown donor: ${name} (see --list)" >&2
    failures=$((failures + 1))
    continue
  fi
  target="${DEST}/${name}"
  pin="${DONOR_PINS[${name}]:-}"
  if [ -d "${target}/.git" ]; then
    echo "[skip] ${name}: already cloned"
  elif [ -d "${target}" ] && [ -n "$(ls -A "${target}" 2>/dev/null)" ]; then
    echo "[warn] ${name}: non-git directory present; leaving untouched" >&2
    continue
  else
    if [ -n "${pin}" ] || [ "${FULL_CLONE}" -eq 1 ]; then
      echo "[clone] ${name} (full) <- ${url}"
      git clone --no-checkout "${url}" "${target}"
    else
      echo "[clone] ${name} (shallow) <- ${url}"
      git clone --depth 1 "${url}" "${target}"
    fi
  fi
  if [ -n "${pin}" ]; then
    if [[ "${pin}" == tag:* ]]; then
      git -C "${target}" fetch --tags --quiet origin
      git -C "${target}" checkout --quiet "${pin#tag:}"
    else
      git -C "${target}" checkout --quiet "${pin}"
      resolved="$(git -C "${target}" rev-parse HEAD)"
      if [ "${resolved}" != "${pin}" ]; then
        echo "[FAIL] ${name}: HEAD ${resolved} != pinned ${pin}" >&2
        failures=$((failures + 1))
        continue
      fi
    fi
  fi
  head_sha="$(git -C "${target}" rev-parse HEAD 2>/dev/null || echo unknown)"
  printf '%s\t%s\t%s\n' "${name}" "${head_sha}" "${url}" >> "${LOG}"
  echo "[ok] ${name}: ${head_sha}"
done

if [ "${failures}" -gt 0 ]; then
  echo "fetch_donor_checkouts: ${failures} donor(s) failed" >&2
  exit 1
fi
echo "fetch_donor_checkouts: done (${#REQUESTED[@]} donor(s)) -> ${DEST}"
