# 2026-06-26 Nightly Import

## Purpose

Record the first all-in-one refresh after the repository was repositioned as a
historical archive and syntax/IDE experiment workspace.

## Historical Read

- The old all-in-one history has 699 reachable commits across all refs.
- The commit graph starts from two initial roots on 2023-05-05, reflecting the
  duplicated eBioRing/Unka-Malloc history that this repository preserves.
- 2023 focused on lexer, parser, AST, control flow, list operations, resource
  import, FileCheck/lit tests, visitor-based LLVM codegen, type checking, and
  early context modeling.
- 2024 moved through mutable variables, generated LLVM execution, function and
  resource forms, forward/hash parsing, iterator chains, and the old main branch
  line ending at `ceb4c56`.
- 2026 brought the active nightly line: milestone docs, resource topology,
  bounded buffer syntax, documentation policy, pipeline tests, tokenizer
  hardening, RAII migration, parser shadow gates, runtime diagnostics,
  tree-sitter IDE backend work, and typed list operations.
- `2add706` reorganized Styio into the current monorepo module layout on
  2026-05-10.

## Imported Heads

- `styio/` was refreshed from
  `styio-nightly@c49ecacdfe5c99d0bac32f89790752ba13f66ee3`.
- `vityo/` was added from
  `vityo-nightly@eeab7b6cb32e4120d5083f6a77215f2ef8ba0b37`.

Both imports were created from `git archive` output so only tracked repository
content was copied into this workspace.

## Monorepo Adaptations

- The root CMake minimum version now matches the imported Styio compiler module.
- Styio CMake scripts use `STYIO_SOURCE_DIR` and `STYIO_BINARY_DIR` so the
  compiler can still be configured from the all-in-one root.
- Vityo remains a non-CMake module and keeps its Flutter, prototype, Python, and
  governance entrypoints under `vityo/`.
