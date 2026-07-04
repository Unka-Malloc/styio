# styio-all-in-one

This repository is the historical all-in-one workspace for Styio language
experiments, compiler work, and IDE integration. It is also the aggressive
all-in-one branch where the language moves toward pure symbolic syntax:
language builtins are not assumed by the parser or IDE and must be registered
through configuration/manifest surfaces before they become visible.

The active product goal is a deeply coupled compiler + IDE workspace. `vityo/`
defaults to the repo-local `styio/` compiler service when a built binary exists,
and the IDE language-service route consumes Styio's compiler-owned
`check --syntax --json --file` contract rather than a standalone mock parser.

## Release Identity

Published builds from this repository use the release name `styio-preview`.
`styio-preview` is the preview distribution of the combined Styio language and
compiler workspace plus the Vityo IDE workspace; it is not the stable standalone
Styio release line.

## Modules

| Path | Role |
| --- | --- |
| [`styio/`](styio/) | Styio language, compiler, runtime, tests, docs, benchmarks, configuration-driven symbol surfaces, and IDE service contracts |
| [`vityo/`](vityo/) | Vityo IDE, Flutter app, prototypes, adapter contracts, repo-local compiler discovery, governance docs, and product gates |
| `styio-spio/` | Planned package-management module |

The root CMake project currently builds `styio/`. Non-CMake modules such as
`vityo/` keep their own toolchain entrypoints under their module directory.

```bash
cmake -S . -B build/default
cmake --build build/default --target styio
```

## Imported Nightly Heads

This checkout currently folds in:

- `styio-nightly@8ef5720bd3ec800c24867b28371eb620b670cc65`
- `vityo-nightly@6f5183ed3412382c1cb485e7e3c8aa57018c524e`

See [`docs/rollups/2026-06-26-nightly-import.md`](docs/rollups/2026-06-26-nightly-import.md)
and [`docs/rollups/2026-06-28-all-in-one-compiler-ide-coupling.md`](docs/rollups/2026-06-28-all-in-one-compiler-ide-coupling.md)
for the history rollup and import notes.
