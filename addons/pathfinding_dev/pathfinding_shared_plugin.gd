class_name PathfindingSharedPlugin
extends EditorPlugin

func _enter_editor() -> void:
    add_autoload_singleton(
        "PathfinderService",
        "res://addons/pathfinding_dev/core/pathfinderservice.gd"
    )

func _exit_editor() -> void:
    remove_autoload_singleton("PathfinderService")
