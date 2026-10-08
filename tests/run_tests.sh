#!/usr/bin/env bash
set -euo pipefail
addon_dir="$(cd "$(dirname "$0")/.." && pwd)"

for file in "$addon_dir"/*.lua; do
    "${LUAC:-luac}" -p "$file"
done

if rg -n 'SetAttribute|RegisterUnitWatch|UnregisterUnitWatch|\.unit\s*=' "$addon_dir" --glob '*.lua'; then
    echo "Forbidden protected-frame mutation found" >&2
    exit 1
fi

rg -q 'InCombatLockdown' "$addon_dir/PartyFrames.lua"
rg -q 'InCombatLockdown' "$addon_dir/RaidLayout.lua"
echo "GabbaUnitFrames static tests passed."
