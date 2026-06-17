class_name MovementStateComponent
extends Node

## Shared movement state for an agent.

var current_waypoint: Vector2i = Vector2i.ZERO
var has_active_waypoint: bool = false
var requires_path: bool = false

func reset() -> void:
    current_waypoint = Vector2i.ZERO
    has_active_waypoint = false
    requires_path = false
