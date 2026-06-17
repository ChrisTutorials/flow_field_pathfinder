class_name MovementStepResult
extends RefCounted

## Result of advancing an agent one movement tick.

var next_position: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO
var moved: bool = false
var has_arrived: bool = false
var should_advance_waypoint: bool = false

func _init(
    p_next_position: Vector2 = Vector2.ZERO,
    p_facing_direction: Vector2 = Vector2.ZERO,
    p_moved: bool = false,
    p_has_arrived: bool = false,
    p_should_advance_waypoint: bool = false
) -> void:
    next_position = p_next_position
    facing_direction = p_facing_direction
    moved = p_moved
    has_arrived = p_has_arrived
    should_advance_waypoint = p_should_advance_waypoint
