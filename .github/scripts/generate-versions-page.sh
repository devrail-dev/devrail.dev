#!/usr/bin/env bash
# .github/scripts/generate-versions-page.sh
#
# Generates the Tool Versions documentation page for devrail.dev.
# Fetches tool-versions.json release assets from the dev-toolchain repo
# and outputs a complete Hugo markdown page to stdout.
#
# Usage: bash .github/scripts/generate-versions-page.sh
# Requires: gh (GitHub CLI), jq, curl
# Environment: GH_TOKEN must be set (provided by GitHub Actions)

set -euo pipefail

REPO="devrail-dev/dev-toolchain"

# --- Helpers ---

render_table() {
  local json="$1"
  echo "| Tool | Version |"
  echo "|---|---|"
  echo "${json}" | jq -r '.tools | to_entries | sort_by(.key) | .[] | "| \(.key) | \(.value) |"'
}

# --- Frontmatter and intro ---

cat <<'FRONTMATTER'
---
title: "Tool Versions"
linkTitle: "Tool Versions"
weight: 10
description: "Tool versions included in each dev-toolchain container release."
---

<!-- This page is generated automatically by .github/workflows/update-tool-versions.yml -->
<!-- Do not edit manually — changes will be overwritten on the next scheduled run. -->

This page shows the exact tool versions shipped in each release of the
[dev-toolchain container](/docs/container/). It is updated automatically
when new releases are published.

FRONTMATTER

# --- Fetch releases ---
# gh api returns newest first by default. Select non-draft releases and
# extract tag, date, and the tool-versions.json asset download URL.

releases=$(gh api "repos/${REPO}/releases" --paginate --jq '
  .[] | select(.draft == false) |
  {
    tag: .tag_name,
    date: (.published_at | split("T")[0]),
    asset_url: (
      [.assets[] | select(.name == "tool-versions.json") | .url] | first // null
    )
  }
')

# --- Render page ---

first=true
has_previous=false

while IFS= read -r release; do
  tag=$(echo "${release}" | jq -r '.tag')
  date=$(echo "${release}" | jq -r '.date')
  asset_url=$(echo "${release}" | jq -r '.asset_url')

  # Skip releases without a tool-versions.json asset
  if [[ "${asset_url}" == "null" ]]; then
    continue
  fi

  # Download the asset via the GitHub API (works for public and private repos)
  versions_json=$(gh api "${asset_url}" --jq '.' 2>/dev/null) || continue

  if ${first}; then
    echo "## Latest Release: ${tag}"
    echo ""
    echo "Released ${date}."
    echo ""
    render_table "${versions_json}"
    echo ""
    first=false
  else
    if ! ${has_previous}; then
      echo "## Previous Releases"
      echo ""
      has_previous=true
    fi
    echo "<details>"
    echo "<summary><strong>${tag}</strong> (${date})</summary>"
    echo ""
    render_table "${versions_json}"
    echo ""
    echo "</details>"
    echo ""
  fi
done <<< "${releases}"

# Fallback if no releases have the asset yet
if ${first}; then
  echo "No releases with tool version manifests are available yet."
  echo "Version data will appear here after the next dev-toolchain release."
fi
