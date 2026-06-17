class_name PathfinderService
extends RefCounted

## Thin bridge service for Moonbark Idle pathfinding.
##
## This does NOT implement A* itself.
## This owns the game-facing path lifecycle and reusable helpers
## so Moonbark Idle can stop duplicating path cache / invalidation logic.

signal path_invalidated(entity_id: int, position: Vector2i, blocked: bool)

var _pathfinder: Object = null
var _last_targets: Dictionary = {}
var _path_lock: Mutex = Mutex.new()

func initialize(pathfinder: Object) -> void:
    _pathfinder = pathfinder

## Requests a grid path for an entity.
## Returns true if the path was accepted by the underlying pathfinder.
func try_set_path(entity_id: int, start: Vector2i, end: Vector2i) -> bool:
    _path_lock.lock()
    var last_target = _last_targets.get(entity_id, end)
    var changed := last_target != end
    _path_lock.unlock()

    if not changed and _has_active_waypoint(entity_id):
        return true

    if changed:
        clear_path(entity_id)

    var accepted := _pathfinder.try_set_path(entity_id, start, end)
    _path_lock.lock()
    _last_targets[entity_id] = end
    _path_lock.unlock()
    return accepted

func get_current_waypoint(entity_id: int) -> Variant:
    if _pathfinder == null:
        return null
    return _pathfinder.get_current_waypoint(entity_id)

func advance_waypoint(entity_id: int) -> void:
    if _pathfinder == null:
        return
    _pathfinder.advance_waypoint(entity_id)

func clear_path(entity_id: int) -> void:
    if _pathfinder == null:
        return
    _pathfinder.clear_path(entity_id)
    _path_lock.lock()
    _last_targets.erase(entity_id)
    _path_lock.unlock()

func is_at_destination(entity_id: int) -> bool:
    if _pathfinder == null:
        return true
    return _pathfinder.is_at_destination(entity_id)

func _has_active_waypoint(entity_id: int) -> bool:
    return get_current_waypoint(entity_id) != null
