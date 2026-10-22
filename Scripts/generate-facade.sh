#!/bin/bash
# Regenerates Sources/Salon1cAPI/Operations+Payload.generated.swift — the
# opt-in envelope-unwrapping facade — from the freshly generated
# Types+Operations.swift. Run after apply-patches.sh whenever openapi.yaml
# changed; the output is deterministic, so a diff means the spec changed.
set -euo pipefail
cd "$(dirname "$0")/.."

OUT=Sources/Salon1cAPI/Operations+Payload.generated.swift

# A stale facade must never block the build that regenerates the types: move it
# aside for the first build and restore it if the run fails.
PREV=""
if [ -f "$OUT" ]; then
    PREV="$OUT.prev"
    mv "$OUT" "$PREV"
    trap 'mv -f "$PREV" "$OUT"' ERR
fi

swift build

GEN=$(ls .build/plugins/outputs/*/Salon1cAPI/*/OpenAPIGenerator/GeneratedSources/Types+Operations.swift | head -1)
swift Scripts/generate-facade.swift "$GEN" > "$OUT"

swift build

if [ -n "$PREV" ]; then rm "$PREV"; fi
trap - ERR

echo "$(wc -l < "$OUT" | tr -d ' ') lines, $(grep -c 'public func payload' "$OUT") payload() extensions → $OUT"
