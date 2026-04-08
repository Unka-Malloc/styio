#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

report_hits_latest() {
  local title="$1"
  local hits="$2"
  echo "[parser-legacy-audit] ${title}" >&2
  printf '%s\n' "$hits" >&2
}

violations=0

legacy_entry_hits_latest="$(rg -n 'parse_main_block_legacy\(' src || true)"
legacy_entry_hits_latest="$(
  printf '%s\n' "$legacy_entry_hits_latest" \
    | grep -vE '^src/StyioParser/Parser\.(cpp|hpp):' || true
)"
if [[ -n "$legacy_entry_hits_latest" ]]; then
  report_hits_latest \
    "unexpected direct parse_main_block_legacy(...) callsites outside parser core" \
    "$legacy_entry_hits_latest"
  violations=1
fi

testing_harness_hits_latest="$(rg -n 'StyioParserEngine::Legacy|parse_main_block_legacy\(' src/StyioTesting || true)"
if [[ -n "$testing_harness_hits_latest" ]]; then
  report_hits_latest \
    "src/StyioTesting must stay nightly-first; legacy routing is not allowed here" \
    "$testing_harness_hits_latest"
  violations=1
fi

main_entry_hits_latest="$(rg -n 'parse_main_block_with_engine_latest\(' src/main.cpp || true)"
if [[ -z "$main_entry_hits_latest" ]]; then
  echo "[parser-legacy-audit] src/main.cpp no longer routes through parse_main_block_with_engine_latest(...)" >&2
  violations=1
fi

if [[ "$violations" -ne 0 ]]; then
  exit 1
fi

echo "[parser-legacy-audit] ok"
