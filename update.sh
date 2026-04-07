#!/usr/bin/env bash
set -euo pipefail

LATEST=$(curl -sSf "https://api.github.com/repos/sfcompute/cli/releases/latest" | jq -r .tag_name)

if [ -f "versions/${LATEST}.json" ]; then
  echo "Already tracked: ${LATEST}"
  exit 0
fi

echo "New version: ${LATEST}"

declare -A PLATFORM_MAP=(
  ["aarch64-darwin"]="node22-macos-arm64"
  ["x86_64-darwin"]="node22-macos-x64"
  ["aarch64-linux"]="node22-linux-arm64"
  ["x86_64-linux"]="node22-linux-x64"
)

BASE_URL="https://github.com/sfcompute/cli/releases/download/${LATEST}"

TMPFILE=$(mktemp)
echo "{\"version\": \"${LATEST}\", \"platforms\": {" > "$TMPFILE"
first=true
for nix_plat in "${!PLATFORM_MAP[@]}"; do
  asset="${PLATFORM_MAP[$nix_plat]}"
  url="${BASE_URL}/sf-${asset}.zip"
  sha256hex=$(nix-prefetch-url "$url" --type sha256 2>/dev/null)
  sri=$(nix hash convert --hash-algo sha256 --to sri "$sha256hex")
  $first || echo "," >> "$TMPFILE"
  printf '"%s": {"url": "%s", "hash": "%s"}' "$nix_plat" "$url" "$sri" >> "$TMPFILE"
  first=false
done
echo "}}" >> "$TMPFILE"

jq . "$TMPFILE" > "versions/${LATEST}.json"
rm "$TMPFILE"
echo "Created versions/${LATEST}.json"
