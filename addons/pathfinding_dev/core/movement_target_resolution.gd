class_name MovementTargetResolution
extends RefCounted

## Resolved movement target information for one tick.

var immediate_target: Vector2i = Vector2i.ZERO
var can_move: bool = false
var has_active_waypoint: bool = false
var requires_path: bool = false

func _init(
    p_immediate_target: Vector2i = Vector2i.ZERO,
    p_can_move: bool = false,
    p_has_active_waypoint: bool = false,
    p_requires_path: bool = false
) -> void:
    immediate_target = p_immediate_target
    can_move = p_can_move
    has_active_waypoint = p_has_active_waypoint
    requires_path = p_requires_path
