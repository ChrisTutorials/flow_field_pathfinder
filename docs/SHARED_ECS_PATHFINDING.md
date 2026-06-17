# Shared GECS-Compatible Pathfinding

## Short answer

A pathfinder does **not** need game-level knowledge to be useful.

What it needs is a clean split between:

- generic path mechanics,
- game-specific movement policy,
- engine-facing navigation plumbing.

The useful shared place is probably **not** a public “Pathfinder” API in the usual sense. It is more likely a **GECS-compatible path infrastructure package** that both Thistle Tide GDScript and Moonbark Idle GDScript can use.

## Important distinction

There are three different things that often get blurred together.

### 1. Path algorithm

This answers:

> “What is the path from A to B?”

Examples:

- A*
- Godot `NavigationServer` path lookup
- C/native pathfinding entry point
- grid graph search

This usually does **not** need game-specific knowledge.

### 2. Path policy

This answers:

> “What path should this entity prefer?”

Examples:

- avoid crowds,
- prefer scenic routes,
- avoid dangerous terrain,
- prefer stage entrances,
- prefer shortest time over shortest distance,
- avoid paths through private areas.

This usually **does** need game-specific knowledge.

### 3. Path lifecycle

This answers:

> “How does an entity request, receive, follow, cancel, cache, and debug a path?”

Examples:

- request path,
- receive path result,
- follow path,
- cancel stale path,
- cache repeated routes,
- batch queries,
- expose debug state.

This can be mostly generic and GECS-compatible.

## Recommended shared layer

The shared package should own mostly **path lifecycle** and optionally **path algorithm integration**.

It should not own game policy.

Good shared responsibilities:

- path request component,
- path result component,
- path follow component,
- path cache component,
- path query system,
- path cancellation,
- path invalidation,
- path smoothing,
- debug visualization hooks,
- integration with Godot navigation types,
- optional integration with the existing C/native pathfinding entry point.

Bad shared responsibilities:

- Moonbark crowd rules,
- Thistle Tide island traversal rules,
- game-specific terrain labels,
- story/event-specific destination selection,
- special character behaviors.

Those should live in each game.

## Why this could be useful between Thistle Tide and Moonbark Idle

If both games use GECS, a shared GECS-compatible pathfinding package could reduce duplicated boilerplate.

Shared value could include:

- same path request/result components,
- same path-following system,
- same path cache behavior,
- same cancellation model,
- same debug visualization,
- same native/C backend adapter,
- same Godot type conventions,
- same testing approach.

That is more compelling than “a public pathfinder.”

## Where game-level knowledge enters

Game-level knowledge should enter through small adapters or policy components.

For example:

```gdscript
component CostProvider
component GoalSelector
component MovementPolicy
component PathProfile
```

Each game provides its own versions:

- `MoonbarkCostProvider`
- `MoonbarkGoalSelector`
- `MoonbarkMovementPolicy`
- `ThistleTideCostProvider`
- `ThistleTideGoalSelector`
- `ThistleTideMovementPolicy`

The shared path infrastructure calls those adapters without knowing their game-specific details.

## Good shape for the shared package

A good shared package might look like:

```text
addons/pathfinding_gd/
  path_request_component.gd
  path_result_component.gd
  path_follow_component.gd
  path_cache_component.gd
  path_query_system.gd
  path_follow_system.gd
  path_cost_provider.gd
  path_goal_selector.gd
  path_policy.gd
  path_debug_overlay.gd
```

Game projects would provide:

```text
Thistle Tide:
  thistle_tide_cost_provider.gd
  thistle_tide_goal_selector.gd
  thistle_tide_movement_policy.gd

Moonbark Idle:
  moonbark_cost_provider.gd
  moonbark_goal_selector.gd
  moonbark_movement_policy.gd
```

## Decision rule

This shared implementation makes sense if Thistle Tide GDScript and Moonbark Idle GDScript both need the same generic path lifecycle.

It does **not** make sense if each game needs totally different:

- movement models,
- path cost models,
- destination selection,
- caching rules,
- debug needs,
- or native backend behavior.

## Recommended position

The best version of this plugin is probably:

> A shared GECS-compatible path infrastructure package, not a public general-purpose pathfinder.

It should provide reusable GECS components and lifecycle behavior, while each game supplies its own policy adapters.
