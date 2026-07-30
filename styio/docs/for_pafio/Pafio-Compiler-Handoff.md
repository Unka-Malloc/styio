# Pafio Compiler Handoff

**Purpose:** Freeze the Styio side of the Pafio project-workflow compiler handoff.

**Last updated:** 2026-07-30

## Owner Boundary

- Pafio owns manifest, lock, resolution, metadata, dependency sync, local
  project workflows, vendor, pack, and publish-client behavior.
- Styio is a system-provided compiler. It owns compile-plan consumption,
  compilation, diagnostics, receipts, runtime events, and its machine
  capability document.
- Styio Platform owns registry services, hosted workspaces, cloud jobs, and
  workers.
- Vityo consumes each owner's public machine contract and does not inspect
  Pafio-private storage.

## Machine Contract

1. Pafio produces compile-plan v1 with
   `generated_by.tool = "pafio"`.
2. Styio accepts that producer identity and validates the requested contract
   version before compilation.
3. `styio --machine-info=json` advertises supported compiler contracts.
4. Diagnostics, receipts, and runtime events remain Styio documents; Pafio
   wraps only project-workflow intent, target, and status.

Pafio does not install, update, switch, pin, or cache Styio. System package
distribution is an external prerequisite.

## Validation

The owning Styio repository validates Pafio compile-plan interoperation and
machine-info output. Cross-repository acceptance pins immutable Styio and Pafio
revisions before running the product matrix.
