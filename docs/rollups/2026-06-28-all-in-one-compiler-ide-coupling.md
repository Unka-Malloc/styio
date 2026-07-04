# 2026-06-28 All-in-one Compiler + IDE Coupling

**Purpose:** Record the second nightly import and the first concrete compiler/IDE coupling layer for `styio-all-in-one`.

**Last updated:** 2026-06-28

## Release Identity

Published builds from `styio-all-in-one` use the release name `styio-preview`.
`styio-preview` is the preview distribution of the combined Styio language and
compiler workspace plus the Vityo IDE workspace; it is not the stable standalone
Styio release line.

## Imported Heads

- `styio-nightly@8ef5720bd3ec800c24867b28371eb620b670cc65`
- `vityo-nightly@6f5183ed3412382c1cb485e7e3c8aa57018c524e`

The import uses tracked Git snapshots from the two local nightly repositories
and keeps their `.git` metadata, build outputs, caches, and local editor state
out of `styio-all-in-one`.

## Coupling Decisions

1. `styio/` remains the compiler authority. Vityo does not grow a second parser
   or builtin table.
2. `vityo/` now discovers the repo-local all-in-one compiler before falling
   back to platform `styio` binaries.
3. The IDE language-service connector calls `styio check --syntax --json --file`
   as the default machine contract.
4. `--config <path>` is accepted by syntax-check so project context and future
   config-driven symbol manifests can flow through the same IDE route.
5. CMake paths inside `styio/` use `STYIO_SOURCE_DIR` and `STYIO_BINARY_DIR`
   so the compiler can build as a submodule of the root all-in-one project.

## Language Branch Rule

`styio-all-in-one` is the aggressive symbolic branch. Parser, compiler service,
and IDE code must not assume predeclared language builtin functions. Builtin-like
capabilities need to enter through configuration or manifest surfaces before
they are visible to diagnostics, completion, lowering, or runtime binding.

## Validation Focus

The immediate validation target is the source-level seam:

- Styio syntax-check accepts IDE project context without executing code.
- Vityo decodes Styio's syntax-check envelope as compiler-owned diagnostics.
- Vityo registers `all-in-one-styio-language-service` when the local compiler
  binary exists under the root build tree.
