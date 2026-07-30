# styio-all-in-one

This repository is the aggregate workspace for the Styio product family.

Use Pafio for project workflows and system Styio for compilation. Vityo consumes Pafio machine contracts for local projects and Styio Platform APIs for hosted workspaces.

## Modules

| Path | Role |
| --- | --- |
| [`styio/`](styio/) | Styio language, compiler, runtime, tests, docs, and benchmarks |
| `pafio-nightly/` | Pafio package management and project workflow entry |
| `vityo-nightly/` | Vityo visual client |

The root CMake project builds `styio/` and includes Pafio or Vityo only when a checked-out sibling module provides its own `CMakeLists.txt`.

```bash
cmake -S . -B build
cmake --build build --target styio
```
