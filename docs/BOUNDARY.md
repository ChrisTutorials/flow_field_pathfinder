# Boundary: GDScript Plugin vs C# Project Code

## Canonical source

Use the workspace boundary doc as the single source of truth:

- `/home/chris/gamedev/godot/projects/docs/plugin-game-boundaries.md`

This plugin boundary is intentionally thin here. It exists mainly to:

- prevent designing this plugin around Friflo ECS concepts,
- keep Godot-facing path seam code in `godot/gdscript/plugins/pathfinding_dev`,
- keep MoonBark C# runtime, policy, and native backend code in `godot/projects/...`.

If a proposed change would require `Friflo.Engine.ECS` or MoonBark plugin bindings here, it probably belongs in `godot/projects/...`, not this plugin.
