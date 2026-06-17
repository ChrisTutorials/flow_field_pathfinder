class_name MovementTargetRequest
extends RefCounted

## Inputs required to resolve the immediate movement target for one tick.

var current_world_position: Vector2 = Vector2.ZERO
var move_target: Vector2i = Vector2i.ZERO
var current_waypoint: Vector2i = Vector2i.ZERO
var tile_size: float = 16.0
var grid_bounds: Rect2i = Rect2i()
var navigation_mode: NavigationMode = NavigationMode.DIRECT

func _init(
    p_current_world_position: Vector2 = Vector2.ZERO,
    p_move_target: Vector2i = Vector2i.ZERO,
    p_current_waypoint: Vector2i = Vector2i.ZERO,
    p_tile_size: float = 16.0,
    p_grid_bounds: Rect2i = Rect2i(),
    p_navigation_mode: NavigationMode = NavigationMode.DIRECT
) -> void:
    current_world_position = p_current_world_position
    move_target = p_move_target
    current_waypoint = p_current_waypoint
    tile_size = p_tile_size
    grid_bounds = p_grid_bounds
    navigation_mode = p_navigation_mode
