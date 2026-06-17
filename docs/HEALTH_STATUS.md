# Health Status

## Overall status

**Status: RED — placeholder only**

This repository currently has strategic value as a documented boundary and sanctioned native escape hatch, but it has **no implemented plugin functionality** yet.

The repo is intentionally empty except for the `addons/` placeholder. There is no source, no public API, no tests, and no integration with the Moonbark game yet.

## Why this repo exists

This plugin is meant to be a **bridge plugin**, not a full pathfinding engine.

Its intended value is to sit between:

- Moonbark’s GDScript game logic
- GECS-style entity workflows
- Godot’s built-in navigation stack

It should make pathfinding easier, cleaner, and more efficient without duplicating Godot’s navigation system.

## Health by area

### Architecture
**Status: YELLOW**

The intended direction is clear:
- use Godot types where possible
- keep game policy out of the plugin
- bridge to Godot navigation
- only go native if profiling demands it

However, the architecture is not implemented yet.

### Implementation
**Status: RED**

There is no implementation.

Current state:
- no pathfinding API
- no components
- no systems
- no cache
- no native backend
- no examples

### Integration
**Status: RED**

The plugin is not yet integrated with:
- Moonbark
- GECS
- Godot navigation helpers
- any game-level pathfinding workflow

### Performance
**Status: UNKNOWN**

There is no implementation to measure yet.

Important note:
- native code should not be added just because it is possible
- it should only be added if profiling shows GDScript is the bottleneck

### Test coverage
**Status: RED**

There are no tests or smoke checks yet.

### Documentation
**Status: YELLOW**

The README exists and now points to:
- `docs/ROADMAP.md`
- `docs/HEALTH_STATUS.md`

This is better than a blind placeholder, but the docs are still early-stage.

### Release readiness
**Status: RED**

This is not release-ready.

It should not be pinned by Moonbark until the roadmap reaches at least Phase 1 or Phase 2.

## Current risks

### 1. Overbuilding
The plugin could become too large if it tries to replace Godot navigation.

### 2. Premature native code
A C/GDExtension backend should only appear after profiling proves it is needed.

### 3. Game-specific coupling
The plugin should not absorb Moonbark-specific movement rules.

### 4. Duplicate work
If Godot already solves a pathfinding need cleanly, the plugin should not reimplement it.

## Current strengths

### 1. Clear boundary
The plugin has a defined purpose: bridge, not engine.

### 2. Good fit for GECS
A generic path service can sit cleanly behind GECS components and systems.

### 3. Godot-native design
Using Godot’s built-in types keeps the API idiomatic and efficient.

### 4. Strategic value
This is the sanctioned escape hatch for future native optimization.

## Recommended next actions

1. Finish the boundary docs.
2. Create a minimal GDScript API.
3. Add GECS-friendly path components.
4. Validate that the API simplifies Moonbark code.
5. Only then consider performance work or native backend exploration.

## Health summary

| Area | Status |
|---|---|
| Architecture | YELLOW |
| Implementation | RED |
| Integration | RED |
| Performance | UNKNOWN |
| Tests | RED |
| Docs | YELLOW |
| Release readiness | RED |

## Bottom line

The plugin has **strategic value**, but not yet **operational value**.

Its health will improve only when it starts providing a clean bridge API over Godot navigation and begins reducing pathfinding boilerplate in the game project.
