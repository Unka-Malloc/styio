# styio-all-in-one

This repository is the monorepo home for Styio and its client-side modules.

## Modules

| Path | Role |
| --- | --- |
| [`styio/`](styio/) | Styio language, compiler, runtime, tests, docs, and benchmarks |
| `styio-spio/` | Planned package-management module |
| `vityo-nightly/` | Planned Vityo visual client module |

The root CMake project currently builds `styio/` and will include sibling modules when they provide their own `CMakeLists.txt`.

```bash
cmake -S . -B build
cmake --build build --target styio
```
