# Flow Field Pathfinder

High-performance Dijkstra-based flow-field pathfinder as a Godot 4 GDExtension (C++).

## What it does

A **flow field** (aka vector field) precomputes the direction to walk from *every* cell
toward one or more targets. All agents at any cell just look up the precomputed
direction — O(1) per agent per frame, regardless of how many agents share the field.

This makes flow fields ideal for **swarms / armies / hordes** where many agents
navigate toward the same goal simultaneously.

### Algorithm

1. **Dijkstra** from all targets outward (multi-source BFS with costs), computing
   shortest distance from every walkable cell to the nearest target.
2. For each cell, pick the **8-connected** neighbour with the lowest distance → store
   that as a direction index (N, NE, E, SE, S, SW, W, NW).
3. Agents sample `get_direction(cell, field_id)` and follow the vector. No per-agent
   pathfinding needed.

Costs: cardinal = 10, diagonal = 14 (≈ √2 × 10), matching standard integer A*
heuristics.

## API

```gdscript
var ff := FlowFieldPathfinder.new()

# Set the grid region (cell coordinates).
ff.configure(Rect2i(Vector2i.ZERO, Vector2i(100, 100)))

# Obstacles: PackedByteArray where 1 = solid, 0 = walkable (indexed y * width + x).
# Targets: Array of Vector2i goal cells.
var field_id := ff.compute_field(obstacles, targets)

# Query: what direction should an agent at this cell walk?
var dir: Vector2i = ff.get_direction(cell, field_id)  # one of 8 directions, or (0,0)

# Free when no longer needed.
ff.free_field(field_id)
```

## Using with 3D worlds (2.5D games)

This plugin operates on a **2D grid** (`Vector2i` cells, `Rect2i` region).
For a 3D Godot project (X/Z horizontal, Y vertical), use the flow field on the
**XZ plane** and handle height separately:

```gdscript
# Map 3D world position → 2D flow field cell.
var cell := Vector2i(
    int(world_position.x / cell_size.x),
    int(world_position.z / cell_size.y),
)

# Get the 2D direction from the flow field.
var dir_2d: Vector2i = flow_field.get_direction(cell, field_id)

# Apply on the XZ plane; Y (height) is handled by terrain / gravity / NavigationServer3D.
var move_direction := Vector3(dir_2d.x, 0.0, dir_2d.y).normalized()
```

**Height (Y) is resolved separately** — the flow field tells you *which way to walk
on the ground*, and your movement system applies terrain height via:
- `NavigationServer3D.get_closest_point()` for nav-mesh surfaces, or
- A downward raycast to the terrain collider, or
- The terrain's heightmap lookup.

### When to use this vs. full 3D pathfinding

| Scenario | Use this (2D flow field on XZ) | Use GridAStarPathProvider3D |
|---|---|---|
| Ground-based movement (most 2.5D games) | ✅ | Overkill |
| Many agents sharing one goal (swarm / army) | ✅ (O(1) per agent) | Slower (per-agent A*) |
| Few agents, different goals | Acceptable | ✅ Better |
| Flying / underwater agents | ❌ | ✅ |
| Multi-level terrain (bridges, stacked floors) | ❌ (see layered approach below) | ✅ |

### Multi-level terrain (bridges, stacked floors)

If your world has multiple walkable layers at the same XZ coordinate, use
**layered flow fields** rather than a full 3D extension:

- One `FlowFieldPathfinder` per floor / layer.
- Transition nodes (stairs, ramps, elevators) connect layers.
- Agents route: current-layer flow field → transition node → next-layer flow field.

This keeps each layer cheap (2D) and avoids the cubic memory/compute cost of a full
3D grid. A full 3D flow field extension is only justified for truly volumetric movement
(space games, voxel worlds) — see [#3](https://github.com/ChrisTutorials/flow_field_pathfinder/issues/3).

## Building from source

Requires [godot-cpp](https://github.com/godotengine/godot-cpp) (SConstruct-based
GDExtension build). Compile with:

```bash
scons platform=linux target=template_debug  # or template_release
```

The compiled `.so` goes into `addons/flow_field_pathfinder/bin/`.