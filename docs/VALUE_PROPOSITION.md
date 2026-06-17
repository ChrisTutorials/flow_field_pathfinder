# Value Proposition

## Short answer

This plugin is only worth implementing if it provides value beyond the game-level `Pathfinder` seam.

If the game-level implementation already:

- uses Godot-native types,
- wraps the C/native pathfinding entry point cleanly,
- satisfies Moonbark’s current needs,
- and is not causing duplication across projects,

then this plugin should **not** be implemented as a separate pathfinding engine.

The plugin’s value must come from being a **shared bridge layer**, not from duplicating what the game already has.

## Internal studio plugin framing

The best framing is probably not “public pathfinding plugin.”

The better framing is:

> An internal studio path infrastructure package shared by GECS-based GDScript games.

That means it should be designed for known internal consumers, such as:

- Thistle Tide GDScript,
- Moonbark Idle GDScript,
- future GECS-based studio games.

It should not try to be a general-purpose public addon for every Godot project.

As an internal studio plugin, its value is:

- shared GECS path components,
- shared path lifecycle behavior,
- shared Godot navigation integration,
- shared native/C backend adapter if needed,
- reduced duplicated boilerplate,
- consistent debugging and testing patterns.

## What does not count as value

The following are not enough by themselves:

- “It uses Godot types.”
- “It calls the same C pathfinding entry point.”
- “It wraps the game-level `Pathfinder` class.”
- “It exists because plugins are cleaner than game code.”
- “It might be faster someday.”

Since the game is already GDScript, using Godot types is expected. If the native/C entry point already exposes similar behavior, a plugin that only forwards calls has very low value.

## Where the value could be

The plugin has value only if it solves one or more of these problems.

### 1. Shared API across multiple game projects

If multiple GDScript games need the same pathfinding seam, this plugin can standardize:

- request shape,
- result shape,
- error handling,
- cancellation,
- caching behavior,
- debug hooks,
- native backend fallback.

Without multiple consumers, this value is weak.

### 2. Separation between engine-facing plumbing and game policy

The plugin can own generic path plumbing:

- path request lifecycle,
- Godot navigation integration,
- path cache,
- path smoothing,
- batching,
- typed response handling.

The game project owns policy:

- Moonbark-specific movement rules,
- crowd rules,
- stage rules,
- entity priorities,
- special terrain costs.

If the game-level `Pathfinder` already separates these cleanly, the plugin adds little.

### 3. GECS integration

The plugin can provide generic GECS-friendly components and systems:

- path request component,
- path result component,
- path follow component,
- path cache component,
- path query system.

This is valuable if the plugin makes GECS integration cleaner than the game-level implementation.

If the game-level implementation already has these components and systems, the plugin is probably unnecessary.

### 4. Production hardening

The plugin can become the sanctioned release artifact:

- documented API,
- tests or smoke checks,
- example scenes,
- compatibility notes,
- versioning,
- release gate checklist.

This matters if Moonbark needs a stable, versioned pathfinding bridge that can be pinned independently.

### 5. Native escape hatch

The plugin can reserve the sanctioned native backend path.

But this is only valuable if profiling later shows that GDScript path orchestration is the bottleneck. The native backend should not be the reason to create the plugin unless that performance problem already exists.

## Decision rule

Implement the plugin only if at least one of these is true:

- Moonbark needs a stable, versioned pathfinding bridge separate from game logic.
- The game-level `Pathfinder` is becoming too coupled to Moonbark-specific policy.
- Multiple game projects need the same pathfinding API.
- GECS integration would be cleaner through a shared plugin.
- The plugin reduces duplicated pathfinding boilerplate.
- Profiling shows a native-backed bridge is necessary.

Otherwise, keep pathfinding in the game project.

## Kill criteria

Do **not** continue the plugin if it becomes:

- a thin wrapper around the game-level `Pathfinder`,
- a duplicate of Godot navigation APIs,
- a duplicate of the existing C/native pathfinding entry point,
- a Moonbark-specific pathfinding framework,
- a native backend added before profiling justifies it.

## Recommended position

The healthiest current position is:

> This plugin is a candidate bridge layer, not a required implementation.

For now, Moonbark should continue using the game-level pathfinding seam unless the plugin can clearly reduce coupling, standardize behavior, or provide reusable GECS/Godot navigation infrastructure.
