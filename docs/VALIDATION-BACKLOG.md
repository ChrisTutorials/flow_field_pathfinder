# Validation Backlog — pathfinding_dev

**Generated:** 2026-06-17  
**Source tool:** `gdscript-validate`  
This project has GDScript files, so the full 7-engine unified report applies.  
**Total findings:** 4 errors, 5 warnings across 2 rules  
**Files scanned:** 9  
**Engines run:** 8 (ok: 7)  

This document tracks the validation backlog for this project. The unified `gdscript-validate` report runs as part of the gate (see `.gate` → `[report]` section). Each task below is a class of finding; specific files are in the `gdscript-validate` output. Regenerate with:

```bash
gdscript-validate --project . --exclude addons --no-build --json > /tmp/validate.json
python3 scripts/validation/gen-task-sheet.py <Project> /tmp/validate.json > docs/VALIDATION-BACKLOG.md
```

## Summary

| Rule | Severity | Count |
|------|----------|------:|
| `scene-uid-missing` | warning | 5 |
| `class-name-domain-mismatch` | error | 4 |

## Tasks

### 5× `scene-uid-missing` (warning)

**Status:** open  
**Owner:** TBD  
**Suggested fix:** Open the .tscn/.tres/.gd in the Godot editor and save it. Godot will mint a uid= in the header and create a .uid sidecar. For test fixtures intentionally broken, add them to the validator's exclude list or document them as expected-broken.

**Sample occurrences:**

  - `res://addons/pathfinding_dev/core/pathfinder_service.gd`
  - `res://addons/pathfinding_dev/demo/pathfinder_demo.gd`
  - `res://addons/pathfinding_dev/ecs/path_request_component.gd`
  - `res://addons/pathfinding_dev/ecs/path_state_component.gd`
  - `res://addons/pathfinding_dev/pathfinding_shared_plugin.gd`

**Acceptance:**

- [ ] All `scene-uid-missing` findings are 0 in the validator output
- [ ] CI gate passes (or the project owner signs off on the open warnings)
- [ ] Promote `gdscript-validate` from `[report]` to `[blocking]` in `.gate`

### 4× `class-name-domain-mismatch` (error)

**Status:** open  
**Owner:** TBD  
**Suggested fix:** Investigate the rule and fix the underlying issue.

**Sample occurrences:**

  - `addons/pathfinding_dev/core/pathfinder_service.gd`:1
  - `addons/pathfinding_dev/demo/pathfinder_demo.gd`:1
  - `addons/pathfinding_dev/ecs/path_request_component.gd`:1
  - `addons/pathfinding_dev/ecs/path_state_component.gd`:1

**Acceptance:**

- [ ] All `class-name-domain-mismatch` findings are 0 in the validator output
- [ ] CI gate passes (or the project owner signs off on the open warnings)
- [ ] Promote `gdscript-validate` from `[report]` to `[blocking]` in `.gate`

## Per-Engine Detail

### gdscript-validator  (✓, 7ms, 0 findings)

- No findings.

### gdscript-quality  (✓, 5ms, 0 findings)

- No findings.

### gdscript-quarantine  (✓, 2ms, 0 findings)

- No findings.

### gdscript-hotpath  (✓, 3ms, 0 findings)

- No findings.

### duplicate-class-detector  (✓, 1ms, 0 findings)

- No findings.

### uid-resource-graph-validator  (✓, 1ms, 5 findings)

| Severity | Rule | Path | Line |
|----------|------|------|-----:|
| warning | `scene-uid-missing` | `res://addons/pathfinding_dev/core/pathfinder_service.gd` | 0 |
| warning | `scene-uid-missing` | `res://addons/pathfinding_dev/demo/pathfinder_demo.gd` | 0 |
| warning | `scene-uid-missing` | `res://addons/pathfinding_dev/ecs/path_request_component.gd` | 0 |
| warning | `scene-uid-missing` | `res://addons/pathfinding_dev/ecs/path_state_component.gd` | 0 |
| warning | `scene-uid-missing` | `res://addons/pathfinding_dev/pathfinding_shared_plugin.gd` | 0 |

### gdscript-class-resolver  (✓, 1ms, 0 findings)

- No findings.

### gdscript-domain-validator  (✗, 1ms, 4 findings)

| Severity | Rule | Path | Line |
|----------|------|------|-----:|
| error | `class-name-domain-mismatch` | `addons/pathfinding_dev/core/pathfinder_service.gd` | 1 |
| error | `class-name-domain-mismatch` | `addons/pathfinding_dev/demo/pathfinder_demo.gd` | 1 |
| error | `class-name-domain-mismatch` | `addons/pathfinding_dev/ecs/path_request_component.gd` | 1 |
| error | `class-name-domain-mismatch` | `addons/pathfinding_dev/ecs/path_state_component.gd` | 1 |

## Workflow

1. Run the validator to regenerate this report.
2. Triage by rule. Each rule has a Suggested fix above.
3. Mark tasks `[x]` as you clear them.
4. When the report is empty (or only expected warnings remain), promote:
   ```ini
   [report]
   gdscript-validate --project . --exclude addons
   ```
   to:
   ```ini
   [blocking]
   gdscript-validate --project . --exclude addons --strict
   ```
5. Add the fix to the project's ROADMAP.md and link to this document.

