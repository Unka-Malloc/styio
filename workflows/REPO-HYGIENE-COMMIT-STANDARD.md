# Repository Hygiene Commit Standard

Root CI reuses the imported Styio hygiene gate against the all-in-one repository tree.

The referenced gate entrypoints are module-local:

- `scripts/repo-hygiene-gate.py` maps to `styio/scripts/repo-hygiene-gate.py`.
- `scripts/delivery-gate.sh` maps to `styio/scripts/delivery-gate.sh`.

All root-tracked editor metadata, local caches, build outputs, fuzz artifacts, and generated reports stay ignored or removed from version control. Intentional binary fixtures are recorded in `configs/repo-hygiene-allowlist.txt`.
