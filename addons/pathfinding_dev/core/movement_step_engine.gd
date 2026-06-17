class_name MovementStepEngine
extends RefCounted

## Advances an agent toward its immediate target by one simulation tick.

static func tick(request: MovementStepRequest) -> MovementStepResult:
    var target_world := _grid_to_world(request.immediate_target, request.tile_size)
    var dx := target_world.x - request.current_position.x
    var dy := target_world.y - request.current_position.y
    var dist_sq := dx * dx + dy * dy
    var facing := _resolve_facing(dx, dy, dist_sq)

    if dist_sq <= request.arrival_threshold * request.arrival_threshold:
        var clamped := _clamp_position(request.current_position, request.tile_size, request.grid_bounds)
        return MovementStepResult.new(
            clamped,
            facing,
            false,
            not request.has_active_waypoint,
            request.has_active_waypoint
        )

    var dist := sqrt(dist_sq)
    var step := request.speed * request.delta_time
    var max_move := max(0.0, dist - request.arrival_threshold)

    var next_position: Vector2
    var arrived: bool
    var advance_waypoint: bool

    if step >= max_move:
        var inv_dist := 1.0 / dist if dist > 0.0 else 0.0
        next_position = Vector2(
            request.current_position.x + dx * inv_dist * max_move,
            request.current_position.y + dy * inv_dist * max_move
        )
        next_position = _clamp_position(next_position, request.tile_size, request.grid_bounds)
        arrived = not request.has_active_waypoint
        advance_waypoint = request.has_active_waypoint
    else:
        var inv_dist := 1.0 / dist
        next_position = Vector2(
            request.current_position.x + dx * inv_dist * step,
            request.current_position.y + dy * inv_dist * step
        )
        next_position = _clamp_position(next_position, request.tile_size, request.grid_bounds)
        arrived = false
        advance_waypoint = false

    var moved := next_position != request.current_position
    return MovementStepResult.new(next_position, facing, moved, arrived, advance_waypoint)

static func _resolve_facing(dx: float, dy: float, dist_sq: float) -> Vector2:
    if dist_sq <= 0.001:
        return Vector2.ZERO

    if abs(dx) >= abs(dy):
        return Vector2.RIGHT if dx >= 0.0 else Vector2.LEFT

    return Vector2.DOWN if dy >= 0.0 else Vector2.UP

static func _grid_to_world(grid: Vector2i, tile_size: float) -> Vector2:
    return Vector2(grid.x * tile_size, grid.y * tile_size)

static func _clamp_position(position: Vector2, tile_size: float, bounds: Rect2i) -> Vector2:
    if bounds != Rect2i():
        var min_pos := Vector2(bounds.position.x * tile_size, bounds.position.y * tile_size)
        var max_pos := Vector2(
            (bounds.position.x + bounds.size.x) * tile_size,
            (bounds.position.y + bounds.size.y) * tile_size
        )
        return Vector2(clamp(position.x, min_pos.x, max_pos.x), clamp(position.y, min_pos.y, max_pos.y))
    return position
