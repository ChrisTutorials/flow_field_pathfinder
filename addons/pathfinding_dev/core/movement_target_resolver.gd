class_name MovementTargetResolver
extends RefCounted

## Determines the immediate movement target for one tick,
## including path-only fallback rules.

static func resolve(request: MovementTargetRequest) -> MovementTargetResolution:
    var immediate_target := request.current_waypoint
    if immediate_target == Vector2i.ZERO:
        immediate_target = _clamp_to_bounds(request.move_target, request.grid_bounds)

    if request.current_waypoint != Vector2i.ZERO:
        return MovementTargetResolution.new(
            immediate_target,
            true,
            true,
            false
        )

    if request.navigation_mode == NavigationMode.PATH_ONLY:
        var current_grid := _world_to_grid(request.current_world_position, request.tile_size)
        var can_move := current_grid == immediate_target
        return MovementTargetResolution.new(
            immediate_target,
            can_move,
            false,
            not can_move
        )

    return MovementTargetResolution.new(
        immediate_target,
        true,
        false,
        false
    )

static func _world_to_grid(world: Vector2, tile_size: float) -> Vector2i:
    return Vector2i(floor(world.x / tile_size), floor(world.y / tile_size))

static func _clamp_to_bounds(position: Vector2i, bounds: Rect2i) -> Vector2i:
    if bounds != Rect2i():
        return Vector2i(
            clamp(position.x, bounds.position.x, bounds.position.x + bounds.size.x - 1),
            clamp(position.y, bounds.position.y, bounds.position.y + bounds.size.y - 1)
        )
    return position
