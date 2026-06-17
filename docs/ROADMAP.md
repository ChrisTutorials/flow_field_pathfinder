# Pathfinding Plugin Roadmap

## Purpose

This plugin is intended to be a **bridge layer** between game-level pathfinding policy and Godot’s native navigation stack.

The goal is not to replace Godot’s navigation system, and not to become a game-specific pathfinding engine. The goal is to provide a clean, typed, reusable seam for:

- GDScript game code
- GECS-based entity workflows
- Godot `NavigationServer`
- Godot `NavigationAgent2D` / `NavigationAgent3D`
- optional native-backed hot paths later, only if profiling demands it

## Guiding principles

1. **Use Godot types first**
   - Prefer built-in Godot types such as `Vector2`, `Vector3`, `Array`, `Dictionary`, `PackedVector2Array`, and `PackedVector3Array`.
   - Keep the public API idiomatic to Godot.

2. **Bridge, don’t duplicate**
   - Do not reimplement Godot navigation unless there is a clear gap.
   - Use this plugin to simplify, standardize, and accelerate access to existing navigation features.

3. **Keep game policy out of the plugin**
   - The plugin should expose generic path services and helpers.
   - Moonbark-specific rules should stay in the game project.

4. **Use native code only when justified**
   - The plugin may eventually use C/GDExtension for hot loops.
   - That should be driven by profiling, not by preference.

5. **Design for ECS-friendly reuse**
   - The plugin should support generic components, queries, and systems.
   - It should not assume one specific game architecture.

## Roadmap

### Phase 0 — Establish the boundary

**Goal:** Make the plugin’s purpose and health explicit.

Deliverables:
- `ROADMAP.md`
- `HEALTH_STATUS.md`
- README links to both documents
- Clear statement that this is a bridge plugin, not a full pathfinding engine

Success criteria:
- Anyone reading the repo can understand what the plugin is and is not.
- The Moonbark release gate is documented.
- The repo no longer feels like an ambiguous placeholder.

---

### Phase 1 — GDScript bridge API

**Goal:** Create a clean GDScript-facing API over Godot navigation primitives.

Deliverables:
- Basic path request/response types
- Thin wrappers around Godot navigation APIs
- A small public service entry point
- No custom pathfinding engine unless needed

Candidate API shape:
- `Pathfinder.request_path(...)`
- `Pathfinder.get_path(...)`
- `Pathfinder.smooth_path(...)`
- `Pathfinder.is_path_valid(...)`

Success criteria:
- Game code can ask for paths without touching Godot internals directly.
- The API uses Godot-native types.
- The plugin remains small and maintainable.

---

### Phase 2 — GECS integration

**Goal:** Make pathfinding easy to use from an ECS-style game project.

Deliverables:
- Generic path components
- Path request lifecycle helpers
- Query-friendly systems
- Optional path cache component
- Clear separation between plugin primitives and game-specific policy

Success criteria:
- The game can plug pathfinding into GECS without custom glue in every system.
- Path requests are easy to observe, debug, and cancel.
- The plugin stays game-agnostic.

---

### Phase 3 — Performance and reuse layer

**Goal:** Add the bridge features that actually justify the plugin’s existence.

Deliverables:
- Path caching
- Batched path queries
- Reusable buffers where possible
- Path smoothing
- Query throttling
- Optional debug visualization hooks

Success criteria:
- The plugin reduces duplicated boilerplate across game projects.
- It improves performance predictability.
- It does not become a second navigation system.

---

### Phase 4 — Optional native backend

**Goal:** Add native-backed acceleration only if profiling proves it is needed.

Deliverables:
- C/GDExtension hot-path candidate
- GDScript-facing API remains unchanged
- Benchmark before and after
- Clear fallback path if native code is unavailable

Success criteria:
- The native layer improves measurable performance.
- The public API stays stable.
- The plugin still works without the native backend.

---

### Phase 5 — Production hardening

**Goal:** Make the plugin release-ready.

Deliverables:
- Tests or smoke checks
- Example scenes
- Documentation
- Versioning notes
- Compatibility notes for Godot versions
- Release gate checklist

Success criteria:
- The plugin is safe to pin in a Moonbark release.
- The game can use it as the sanctioned escape hatch without ambiguity.

## What this plugin should not become

- A full replacement for Godot navigation
- A game-specific pathfinding engine
- A large framework that duplicates what Godot already provides
- A native backend before profiling justifies it

## Recommended next step

Start with **Phase 0** and **Phase 1**:
1. Document the boundary.
2. Create a small GDScript API.
3. Validate that it makes Moonbark code simpler before adding anything else.
