class_name MovementSystem
extends Node

## Shared movement step system.
##
## Operates over lightweight agent tables and shared movement helpers.
## Games provide their own facing, arrival callbacks, and speed policies.

signal arrived(entity_id: int)

var _speed_helper: MovementSpeedHelper = MovementSpeedHelper.new()

func update(delta: float, agents: Array, path_provider: Object = null) -> void:
    for agent in agents:
        if not agent is Dictionary:
            continue
        _tick_agent(agent, delta, path_provider)

func _tick_agent(agent: Dictionary, delta: float, path_provider: Object) -> void:
    var entity_id: int = agent.get("id", -1)
    var state: Dictionary = agent.get("state", {})
    var path: Dictionary = agent.get("path", {})
    var movement: Dictionary = agent.get("movement", {})

    if not state.get("is_moving", false):
        return

    var current_world: Vector2 = agent.get("world_position", Vector2.ZERO)
    var move_target: Vector2i = state.get("move_target", Vector2i.ZERO)
    var current_waypoint: Vector2i = path.get("current_waypoint", Vector2i.ZERO)
    var tile_size: float = movement.get("tile_size", 16.0)
    var grid_bounds: Rect2i = movement.get("grid_bounds", Rect2i())
    var base_speed: float = movement.get("base_speed", 64.0)
    var effective_speed: float = _speed_helper.resolve(base_speed, agent)

    var target_request = MovementTargetRequest.new(
        current_world,
        move_target,
        current_waypoint,
        tile_size,
        grid_bounds,
        _resolve_navigation_mode(path_provider, entity_id)
    )

    var target_resolution = MovementTargetResolver.resolve(target_request)
    if not target_resolution.can_move:
        return

    var step_request = MovementStepRequest.new(
        current_world,
        target_resolution.immediate_target,
        tile_size,
        delta,
        effective_speed,
        movement.get("arrival_threshold", tile_size / 2.0 + 1.0),
        grid_bounds,
        target_resolution.has_active_waypoint
    )

    var step_result = MovementStepEngine.tick(step_request)
    movement["world_position"] = step_result.next_position
    agent["facing_direction"] = step_result.facing_direction

    if step_result.should_advance_waypoint:
        _advance_waypoint(entity_id, path_provider)

    var should_arrive := false
    if step_result.has_arrived:
        should_arrive = true

    if should_arrive:
        arrived.emit(entity_id)

func _resolve_navigation_mode(path_provider: Object, entity_id: int) -> NavigationMode:
    if path_provider == null:
        return NavigationMode.DIRECT
    if path_provider.get_current_waypoint(entity_id) != null:
        return NavigationMode.PATH_ONLY
    return NavigationMode.DIRECT

func _advance_waypoint(entity_id: int, path_provider: Object) -> void:
    if path_provider == null:
        return
    if path_provider.has_method("advance_waypoint"):
        path_provider.advance_waypoint(entity_id)
