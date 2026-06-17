class_name PathStateComponent
extends Node

## Shared ECS-style current path state for an agent.

var destination: Vector2i = Vector2i.ZERO
var current_waypoint: Vector2i = Vector2i.ZERO
var current_waypoint_index: int = 0
var has_path: bool = false
var is_at_destination: bool = true

func reset() -> void:
    destination = Vector2i.ZERO
    current_waypoint = Vector2i.ZERO
    current_waypoint_index = 0
    has_path = false
    is_at_destination = true
