#!/usr/bin/env bash
# sync-scripts.sh — keep a module's scripts/ in step with the module template.
#
# WHY THIS EXISTS
#   "Use this template" copies scripts/ into a new module ONCE. Nothing updates
#   it afterwards, so every module's checker, bootstrap and publication helpers
#   drift silently from mii-kds-module-template — a bug fixed in the template
#   (e.g. the M6 version rule learning prerelease suffixes) never reaches the
#   modules, and each one rediscovers it when its build turns red. This script
#   mirrors what sync-ig-template.sh does for ig-template/: refresh from the
#   source of truth, or fail CI when the copy has drifted.
#
# USAGE
#   scripts/sync-scripts.sh [--ref <git-ref>] [--check]
#     --ref <git-ref>  branch/tag/SHA of mii-kds-module-template to sync from
#                      (default: main — modules follow RELEASED template tooling)
#     --check          do not write; exit 1 if any propagated script differs
#
#   SRC_REPO=<url>     override the template repository (default: the
#                      medizininformatik-initiative/mii-kds-module-template clone URL)
#
# WHAT IS SYNCED
#   Every file in the template's scripts/ except the TEMPLATE-ONLY tooling listed
#   in TEMPLATE_ONLY below (self-check, demo generation, gh-pages index). Files
#   that exist locally but not upstream are reported, never deleted. The commit
#   the copy came from is recorded in scripts/.template-sync.
#
#   In the template repository itself this script is a no-op (the files ARE the
#   source); the workflow skips it there as well.
set -euo pipefail

SRC_REPO="${SRC_REPO:-https://github.com/medizininformatik-initiative/mii-kds-module-template.git}"
REF="main"
CHECK_ONLY="false"
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)   REF="${2:?--ref needs a value}"; shift 2 ;;
    --check) CHECK_ONLY="true"; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

# Tooling that only makes sense in the template repository. Keep in step with
# scripts/README.md ("Template repo only").
TEMPLATE_ONLY=(
  self-check-substitute.sh self-check-substitute.test.mjs
  gen-pages-index.mjs gen-pages-index.test.mjs
  publication-url-consistency.template-test.mjs
  gen-rendering-demo.py demo-en.md demo-de.md rendering-demo-codes.json
)
is_template_only() { local f; for f in "${TEMPLATE_ONLY[@]}"; do [ "$1" = "$f" ] && return 0; done; return 1; }

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
origin_url="$(git -C "${repo_root}" remote get-url origin 2>/dev/null || true)"
case "${origin_url}" in
  *mii-kds-module-template*) echo "This is the template repository itself — scripts/ is the source, nothing to sync."; exit 0 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
export GIT_TERMINAL_PROMPT=0

echo "Fetching ${SRC_REPO} @ ${REF} ..."
git clone --quiet --depth 1 --branch "${REF}" "${SRC_REPO}" "${tmp}/src" 2>/dev/null \
  || { git clone --quiet "${SRC_REPO}" "${tmp}/src" && git -C "${tmp}/src" checkout --quiet "${REF}"; }
src_sha="$(git -C "${tmp}/src" rev-parse HEAD)"

drift=0; local_only=()
while IFS= read -r rel; do
  is_template_only "${rel}" && continue
  src="${tmp}/src/scripts/${rel}"; dst="${repo_root}/scripts/${rel}"
  if [ ! -e "${dst}" ] || ! cmp -s "${src}" "${dst}"; then
    drift=$((drift+1))
    if [ "${CHECK_ONLY}" = "true" ]; then
      [ -e "${dst}" ] && echo "  differs: scripts/${rel}" || echo "  missing: scripts/${rel}"
    else
      mkdir -p "$(dirname "${dst}")"; cp -p "${src}" "${dst}"; echo "  updated: scripts/${rel}"
    fi
  fi
done < <(cd "${tmp}/src/scripts" && find . -type f | sed 's#^\./##' | sort)

while IFS= read -r rel; do
  [ "${rel}" = ".template-sync" ] && continue
  is_template_only "${rel}" && continue
  [ -e "${tmp}/src/scripts/${rel}" ] || local_only+=("${rel}")
done < <(cd "${repo_root}/scripts" && find . -type f | sed 's#^\./##' | sort)
if [ ${#local_only[@]} -gt 0 ]; then
  echo "Present locally but not in the template (left untouched): ${local_only[*]}"
fi

if [ "${CHECK_ONLY}" = "true" ]; then
  if [ "${drift}" -eq 0 ]; then
    echo "scripts/ is in sync with ${SRC_REPO}@${REF} (${src_sha})."
    exit 0
  fi
  echo "::error::scripts/ has DRIFTED from ${SRC_REPO}@${REF} (${src_sha}) in ${drift} file(s)."
  echo "Run scripts/sync-scripts.sh to refresh it."
  exit 1
fi

printf 'source: %s\nref: %s\ncommit: %s\nsynced: %s\n' "${SRC_REPO}" "${REF}" "${src_sha}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "${repo_root}/scripts/.template-sync"
echo "Synced ${drift} file(s) from ${SRC_REPO}@${REF} (${src_sha}); recorded in scripts/.template-sync."
