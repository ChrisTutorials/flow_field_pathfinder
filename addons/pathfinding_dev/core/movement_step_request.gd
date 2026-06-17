class_name MovementStepRequest
extends RefCounted

## Inputs required to advance an agent one movement tick.

var current_position: Vector2 = Vector2.ZERO
var immediate_target: Vector2i = Vector2i.ZERO
var tile_size: float = 16.0
var delta_time: float = 0.0
var speed: float = 64.0
var arrival_threshold: float = 9.0
var grid_bounds: Rect2i = Rect2i()
var has_active_waypoint: bool = false

func _init(
    p_current_position: Vector2 = Vector2.ZERO,
    p_immediate_target: Vector2i = Vector2i.ZERO,
    p_tile_size: float = 16.0,
    p_delta_time: float = 0.0,
    p_speed: float = 64.0,
    p_arrival_threshold: float = 9.0,
    p_grid_bounds: Rect2i = Rect2i(),
    p_has_active_waypoint: bool = false
) -> void:
    current_position = p_current_position
    immediate_target = p_immediate_target
    tile_size = p_tile_size
    delta_time = p_delta_time
    speed = p_speed
    arrival_threshold = p_arrival_threshold
    grid_bounds = p_grid_bounds
    has_active_waypoint = p_has_active_waypoint
