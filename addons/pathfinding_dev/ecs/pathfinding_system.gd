class_name PathfindingSystem
extends Node

## Shared path lifecycle.
##
## Operates over lightweight agent tables rather than a concrete ECS type.
## Games provide their own entity representation and path backend provider.

signal path_requested(entity_id: int, start: Vector2i, end: Vector2i)

var _grid_bounds: Rect2i = Rect2i()

func set_grid_bounds(bounds: Rect2i) -> void:
    _grid_bounds = bounds

func is_in_bounds(position: Vector2i) -> bool:
    if _grid_bounds != Rect2i():
        return Rect2i(_grid_bounds.position, _grid_bounds.size).has_point(position)
    return position.x >= 0 and position.y >= 0

func clamp_to_bounds(position: Vector2i) -> Vector2i:
    if _grid_bounds != Rect2i():
        return Vector2i(
            clamp(position.x, _grid_bounds.position.x, _grid_bounds.position.x + _grid_bounds.size.x - 1),
            clamp(position.y, _grid_bounds.position.y, _grid_bounds.position.y + _grid_bounds.size.y - 1)
        )
    return position

func update(delta: float, agents: Array) -> void:
    for agent in agents:
        if not agent is Dictionary:
            continue
        _update_agent(agent)

func _update_agent(agent: Dictionary) -> void:
    var entity_id: int = agent.get("id", -1)
    var state: Dictionary = agent.get("state", {})
    var path: Dictionary = agent.get("path", {})

    if not _is_moving_state(state):
        _clear_path(entity_id, path)
        return

    var start: Vector2i = agent.get("position", Vector2i.ZERO)
    if not is_in_bounds(start):
        _clear_path(entity_id, path)
        return

    var move_target: Vector2i = state.get("move_target", Vector2i.ZERO)
    var last_target: Vector2i = path.get("last_target", move_target)
    if last_target != move_target:
        _clear_path(entity_id, path)
    path["last_target"] = move_target

    if path.get("active", false):
        return

    var end: Vector2i = move_target
    if not is_in_bounds(end):
        end = clamp_to_bounds(end)
        state["move_target"] = end

    if start == end:
        return

    _request_path(entity_id, start, end, path)

func _is_moving_state(state: Dictionary) -> bool:
    return state.get("is_moving", false)

func _request_path(entity_id: int, start: Vector2i, end: Vector2i, path: Dictionary) -> void:
    path["active"] = true
    path["current_waypoint"] = end
    path["current_waypoint_index"] = 0
    path_requested.emit(entity_id, start, end)

func _clear_path(entity_id: int, path: Dictionary) -> void:
    path.erase("active")
    path.erase("current_waypoint")
    path.erase("current_waypoint_index")
    path.erase("last_target")
