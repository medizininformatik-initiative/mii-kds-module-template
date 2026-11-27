#!/usr/bin/env bash
# Install FHIR packages that are published only on the BfArM Zentraler
# Terminologieserver (ZTS) into the FHIR package cache, so SUSHI, the IG
# Publisher, fhir-pkg-tool and the HL7 validator find them there instead of
# failing on the package registry. Called by action.yml next to this file;
# see it for the contract. Issue #55.
#
# Candidates: the direct dependencies in sushi-config.yaml plus ZTS_PACKAGES
# (name#version). A candidate is installed from the ZTS only when it is on the
# ZTS catalog AND not on packages.fhir.org: several catalog packages (e.g.
# dvmd.kdl.r4) are on the registry too, and those must keep loading from there
# without anyone accepting BfArM download conditions.
#
# Environment (all optional):
#   ZTS_ACCEPTED_DOWNLOAD_CONDITIONS  package names whose BfArM download
#                                     conditions are accepted (comma/space/newline)
#   ZTS_PACKAGES                      extra name#version, e.g. transitive needs
#   ZTS_SUSHI_CONFIG                  path of sushi-config.yaml (default ./sushi-config.yaml)
#   FHIR_PACKAGES_DIR                 package cache (default ~/.fhir/packages)
#   ZTS_BASE_URL, ZTS_REGISTRY_URL    endpoints (overridden by the tests)
#
# The download token is masked on GitHub Actions and never printed.
# Compatible with bash 3.2 (macOS), so the tests also run locally.
set -euo pipefail

ZTS_BASE_URL="${ZTS_BASE_URL:-https://terminologien.bfarm.de}"
REGISTRY_URL="${ZTS_REGISTRY_URL:-https://packages.fhir.org}"
PACKAGES_DIR="${FHIR_PACKAGES_DIR:-${HOME}/.fhir/packages}"
SUSHI_CONFIG="${ZTS_SUSHI_CONFIG:-sushi-config.yaml}"
OUTPUT_FILE="${GITHUB_OUTPUT:-/dev/null}"
SUMMARY_FILE="${GITHUB_STEP_SUMMARY:-/dev/null}"
USER_AGENT="mii-kds-module-template zts-packages"
WORK="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/zts-packages.XXXXXX")"
trap 'rm -rf "${WORK}"' EXIT

# One item per line, without blanks; input separated by commas, spaces or newlines.
as_lines() {
  local words="${1:-}" word
  set -f # no globbing while splitting
  # shellcheck disable=SC2086 # deliberate word splitting on spaces/newlines
  for word in ${words//,/ }; do printf '%s\n' "${word}"; done
  set +f
}

contains_line() { printf '%s\n' "$2" | grep -qxF -- "$1"; }

finish() {
  echo "installed=$1" >> "${OUTPUT_FILE}"
  exit 0
}

accepted="$(as_lines "${ZTS_ACCEPTED_DOWNLOAD_CONDITIONS:-}")"

# ── candidates ────────────────────────────────────────────────────────────────
candidates=""
if [[ -f "${SUSHI_CONFIG}" ]]; then
  candidates="$(yq -r '.dependencies // {} | to_entries | .[] | .key + "#" + ((.value | select(kind == "map") | .version) // .value)' "${SUSHI_CONFIG}")"
fi
extra="$(as_lines "${ZTS_PACKAGES:-}")"
while IFS= read -r item; do
  [[ -z "${item}" ]] && continue
  if [[ ! "${item}" =~ ^[^#[:space:]]+#[^#[:space:]]+$ ]]; then
    echo "::error::ZTS_PACKAGES entry '${item}' is not of the form name#version."
    exit 1
  fi
done <<< "${extra}"
candidates="$(printf '%s\n%s\n' "${candidates}" "${extra}" | sed '/^$/d' | sort -u)"

if [[ -z "${candidates}" ]]; then
  echo "No dependencies to check against the ZTS."
  finish ""
fi

# ── ZTS catalog ───────────────────────────────────────────────────────────────
catalog="${WORK}/catalog.json"
if ! curl --fail --silent --show-error --max-time 30 --user-agent "${USER_AGENT}" \
     --header "Accept: application/json" "${ZTS_BASE_URL}/packages/catalog" --output "${catalog}"; then
  if [[ -z "${accepted}" ]]; then
    echo "::warning::The BfArM ZTS catalog could not be fetched; skipping ZTS packages (ZTS_ACCEPTED_DOWNLOAD_CONDITIONS is not set)."
    finish ""
  fi
  echo "::error::The BfArM ZTS catalog (${ZTS_BASE_URL}/packages/catalog) could not be fetched."
  exit 1
fi

# ── keep the ZTS-only candidates ──────────────────────────────────────────────
zts_only=""
problems=0
while IFS= read -r coordinate; do
  name="${coordinate%%#*}"
  version="${coordinate#*#}"
  jq -e --arg n "${name}" 'any(.[]; .name == $n)' "${catalog}" >/dev/null || continue

  # Registry first. 404 = not there; any other failure = unknown.
  registry_meta="${WORK}/registry.json"
  status="$(curl --silent --max-time 30 --user-agent "${USER_AGENT}" --output "${registry_meta}" \
              --write-out '%{http_code}' "${REGISTRY_URL}/${name}" || true)"
  if [[ "${status}" == "200" ]] && jq -e --arg v "${version}" '.versions[$v] != null' "${registry_meta}" >/dev/null 2>&1; then
    echo "${coordinate}: on ${REGISTRY_URL}, loaded from there."
    continue
  fi
  if [[ "${status}" != "200" && "${status}" != "404" ]] && ! contains_line "${name}" "${accepted}"; then
    echo "::warning::${coordinate} is on the ZTS catalog, but ${REGISTRY_URL} could not be checked (HTTP ${status:-none}); not installing it from the ZTS."
    continue
  fi

  if ! jq -e --arg n "${name}" --arg v "${version}" \
       'any(.[]; .name == $n and ((.packageVersions // []) | index($v)) != null)' "${catalog}" >/dev/null; then
    known="$(jq -r --arg n "${name}" '.[] | select(.name == $n) | (.packageVersions // []) | join(", ")' "${catalog}")"
    echo "::error::${coordinate} is not on packages.fhir.org, and the BfArM ZTS has ${name} only in version(s): ${known}."
    problems=$((problems + 1))
    continue
  fi
  if ! contains_line "${name}" "${accepted}"; then
    echo "::error::${coordinate} is available only on the BfArM ZTS. Accept its download conditions on https://terminologien.bfarm.de and add '${name}' to the Actions variable ZTS_ACCEPTED_DOWNLOAD_CONDITIONS."
    problems=$((problems + 1))
    continue
  fi
  zts_only="$(printf '%s\n%s\n' "${zts_only}" "${coordinate}" | sed '/^$/d')"
done <<< "${candidates}"

if (( problems > 0 )); then
  exit 1
fi
if [[ -z "${zts_only}" ]]; then
  echo "No dependency needs the BfArM ZTS."
  finish ""
fi

# ── skip what is already cached ───────────────────────────────────────────────
to_download=""
while IFS= read -r coordinate; do
  if [[ -f "${PACKAGES_DIR}/${coordinate}/package/package.json" ]]; then
    echo "${coordinate}: already in ${PACKAGES_DIR}."
  else
    to_download="$(printf '%s\n%s\n' "${to_download}" "${coordinate}" | sed '/^$/d')"
  fi
done <<< "${zts_only}"

installed=""
if [[ -n "${to_download}" ]]; then
  # ── token: accepts the download conditions of exactly these packages ────────
  names_json="$(printf '%s\n' "${to_download}" | sed 's/#.*//' | sort -u | jq -R . | jq -sc '{packages: .}')"
  token="$(curl --fail --silent --show-error --max-time 30 --user-agent "${USER_AGENT}" \
             --header "Content-Type: application/json" --data "${names_json}" \
             "${ZTS_BASE_URL}/api/generate-token" | jq -r '.token // empty')" || token=""
  if [[ -z "${token}" ]]; then
    echo "::error::The BfArM ZTS did not issue a download token for: $(printf '%s\n' "${to_download}" | paste -sd ' ' -)"
    exit 1
  fi
  if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
    echo "::add-mask::${token}"
  fi

  mkdir -p "${PACKAGES_DIR}"
  while IFS= read -r coordinate; do
    name="${coordinate%%#*}"
    version="${coordinate#*#}"
    tarball="${WORK}/${name}-${version}.tgz"
    # The header goes through stdin, so the token is not in the process list.
    if ! printf 'Authorization: Bearer %s\n' "${token}" | curl --fail --silent --show-error --max-time 300 \
         --user-agent "${USER_AGENT}" --header @- --output "${tarball}" \
         "${ZTS_BASE_URL}/packages/${name}/${version}"; then
      echo "::error::Downloading ${coordinate} from the BfArM ZTS failed."
      exit 1
    fi
    unpacked="${WORK}/${name}#${version}"
    mkdir -p "${unpacked}"
    tar -xzf "${tarball}" -C "${unpacked}"
    rm -f "${tarball}"
    manifest="${unpacked}/package/package.json"
    if [[ ! -f "${manifest}" ]] || \
       [[ "$(jq -r '.name' "${manifest}")" != "${name}" ]] || [[ "$(jq -r '.version' "${manifest}")" != "${version}" ]]; then
      echo "::error::The ZTS download for ${coordinate} is not that package (package/package.json missing or with another name/version)."
      exit 1
    fi
    mv "${unpacked}" "${PACKAGES_DIR}/${name}#${version}"
    echo "${coordinate}: installed from the BfArM ZTS."
    echo "- \`${coordinate}\` installed from the BfArM ZTS" >> "${SUMMARY_FILE}"
    installed="${installed:+${installed},}${coordinate}"
  done <<< "${to_download}"
fi

finish "${installed}"
