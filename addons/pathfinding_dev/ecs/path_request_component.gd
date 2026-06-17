class_name PathRequestComponent
extends Node

## Shared ECS-style path request data for Moonbark Idle-style movement systems.
##
## This is a plain data container meant to be attached to a lightweight
## gameplay entity or held by a system-local agent table.

var start: Vector2i = Vector2i.ZERO
var end: Vector2i = Vector2i.ZERO
var pending: bool = false
var requires_path: bool = false

func create(p_start: Vector2i, p_end: Vector2i) -> PathRequestComponent:
    var instance := PathRequestComponent.new()
    instance.start = p_start
    instance.end = p_end
    instance.pending = true
    instance.requires_path = false
    return instance

func reset() -> void:
    pending = false
    requires_path = false
