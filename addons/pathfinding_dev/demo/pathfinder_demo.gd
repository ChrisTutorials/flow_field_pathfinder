class_name PathfinderDemo
extends Node

## Demo of using the shared pathfinding boundary from Moonbark Idle-style gameplay code.

@onready var service: PathfinderService = PathfinderService.new()

func _ready() -> void:
    var fake_pathfinder := FakePathfinder.new()
    service.initialize(fake_pathfinder)

    service.try_set_path(1, Vector2i(0, 0), Vector2i(2, 3))
    service.try_set_path(2, Vector2i(1, 1), Vector2i(1, 1))

    print("waypoint 1: ", service.get_current_waypoint(1))
    service.advance_waypoint(1)
    print("is at destination 1: ", service.is_at_destination(1))
    service.clear_path(1)
    print("cleared 1: ", service.get_current_waypoint(1) == null)
