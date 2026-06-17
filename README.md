# Internal Studio GECS Pathfinding

Internal studio path infrastructure package for GECS-based GDScript games.

> **Moonbark release gate:** Per `moonbark-idle-gd`'s `DECISIONS.md` (9, 11 & 12), this is the one
> sanctioned native escape hatch (a Rust GDExtension only if a profiler demands it) and must reach
> **production status** before a Moonbark release may pin it. **Status: not started** — empty port
> target; the game uses a local `Pathfinder` seam until this exists.

No matching source exists under `/home/chris/gamedev/godot/projects/maintenance` yet, so this repository is intentionally empty except for the `addons/` placeholder.

## Documentation

- `docs/BOUNDARY.md` minimal local boundary pointer → canonical rule: `/home/chris/gamedev/godot/projects/docs/plugin-game-boundaries.md`
- [Value proposition](docs/VALUE_PROPOSITION.md)
- [Shared GECS-compatible pathfinding](docs/SHARED_ECS_PATHFINDING.md)
- [Roadmap](docs/ROADMAP.md)
- [Health status](docs/HEALTH_STATUS.md)

For repo-wide boundary rules, see the workspace index: `/home/chris/gamedev/godot/projects/docs/README.md`.
