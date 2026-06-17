class_name GridAStarPathProvider
extends RefCounted
## Entity-keyed grid path provider backed by Godot's native AStarGrid2D.
##
## This is the concrete A* implementation PathfinderService delegates to
## (PathfinderService itself only owns cache/invalidation). It satisfies the
## provider contract:
##   try_set_path(entity_id, start, end) -> bool
##   get_current_waypoint(entity_id)     -> Vector2i | null
##   advance_waypoint(entity_id)
##   clear_path(entity_id)
##   is_at_destination(entity_id)        -> bool
##
## Paths are returned as grid CELLS (AStarGrid2D.get_id_path). Pixel
## conversion (cell center) is the movement layer's job
## (MovementTargetResolver.cell_center) so this stays purely topological.

var _astar := AStarGrid2D.new()

## entity_id -> Array[Vector2i] (full cell path including the start cell).
var _paths: Dictionary = {}
## entity_id -> int (index of the current waypoint within its path).
var _indices: Dictionary = {}


## Configure the grid region and cell size. DIAGONAL_MODE_NEVER → 4-connected
## movement (single orthogonal hops), matching the game's tile movement.
func configure(region: Rect2i, cell_size: Vector2 = Vector2.ONE) -> void:
	_astar.region = region
	_astar.cell_size = cell_size
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()


## Mark a cell walkable/solid for routing.
func set_walkable(cell: Vector2i, walkable: bool) -> void:
	if _astar.is_in_boundsv(cell):
		_astar.set_point_solid(cell, not walkable)


## Compute and store a path for an entity. Returns false (and stores nothing)
## when start/end are out of bounds or no route exists.
func try_set_path(entity_id: int, start: Vector2i, end: Vector2i) -> bool:
	if not _astar.is_in_boundsv(start) or not _astar.is_in_boundsv(end):
		return false
	var cells: Array[Vector2i] = _astar.get_id_path(start, end)
	if cells.is_empty():
		return false
	_paths[entity_id] = cells
	# Index 0 is the start cell (== current position); the first waypoint to
	# walk to is the next cell. A zero-length move (start == end) yields a
	# single-cell path already at the destination.
	_indices[entity_id] = 1 if cells.size() > 1 else cells.size()
	return true


## The cell the entity is currently walking toward, or null when the path is
## exhausted / absent.
func get_current_waypoint(entity_id: int) -> Variant:
	var cells: Array = _paths.get(entity_id, [])
	var idx: int = _indices.get(entity_id, 0)
	if idx < 0 or idx >= cells.size():
		return null
	return cells[idx]


## Advance to the next waypoint in the entity's path.
func advance_waypoint(entity_id: int) -> void:
	if _indices.has(entity_id):
		_indices[entity_id] = int(_indices[entity_id]) + 1


## Drop the entity's stored path.
func clear_path(entity_id: int) -> void:
	_paths.erase(entity_id)
	_indices.erase(entity_id)


## True when the entity has no path or has consumed every waypoint.
func is_at_destination(entity_id: int) -> bool:
	var cells: Array = _paths.get(entity_id, [])
	if cells.is_empty():
		return true
	return int(_indices.get(entity_id, 0)) >= cells.size()
