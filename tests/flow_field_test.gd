extends SceneTree
## SceneTree correctness suite for the FlowFieldPathfinder GDExtension.
##
## Verifies the multi-source Dijkstra distance field and 8-connected direction
## selection against hand-computed grids. Run headless:
##
##   godot --headless --path <repo> --script res://tests/flow_field_test.gd
##
## Direction encoding (matches cpp DIR_DX/DIR_DY):
##   N=(0,-1) NE=(1,-1) E=(1,0) SE=(1,1) S=(0,1) SW=(-1,1) W=(-1,0) NW=(-1,-1)

var _passed := 0
var _failed := 0

func _initialize() -> void:
	if not ClassDB.class_exists("FlowFieldPathfinder"):
		_fail("FlowFieldPathfinder class is not registered (GDExtension did not load)")
		_summary()
		quit(1)
		return

	var ff = ClassDB.instantiate("FlowFieldPathfinder")

	_test_open_field_single_target(ff)
	_test_diagonal(ff)
	_test_obstacle_unreachable(ff)
	_test_multiple_targets(ff)
	_test_target_cell_is_zero(ff)
	_test_out_of_bounds(ff)
	_test_invalid_field_id(ff)
	_test_free_field(ff)

	_summary()
	quit(1 if _failed > 0 else 0)


func _test_open_field_single_target(ff) -> void:
	# 5x1 row, target at (4,0). Distances L->R: 40,30,20,10,0.
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(5, 1)))
	var obs := PackedByteArray()
	obs.resize(5)
	var fid: int = ff.compute_field(obs, [Vector2i(4, 0)])
	# Every non-target cell points East (1,0) toward the target.
	_eq(ff.get_direction(Vector2i(0, 0), fid), Vector2i(1, 0), "open 5x1 (0,0)->E")
	_eq(ff.get_direction(Vector2i(2, 0), fid), Vector2i(1, 0), "open 5x1 (2,0)->E")
	# Target cell itself reports no direction.
	_eq(ff.get_direction(Vector2i(4, 0), fid), Vector2i.ZERO, "open 5x1 target->(0,0)")
	ff.free_field(fid)


func _test_diagonal(ff) -> void:
	# 3x3 grid, single target at top-left (0,0).
	# (2,2) is two diagonal steps away (cost 28); best move is NW (-1,-1).
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(3, 3)))
	var obs := PackedByteArray()
	obs.resize(9)
	var fid: int = ff.compute_field(obs, [Vector2i(0, 0)])
	_eq(ff.get_direction(Vector2i(2, 2), fid), Vector2i(-1, -1), "3x3 (2,2)->NW")
	# (2,0) is on the top row; only West (-1,0) is a valid improving move.
	_eq(ff.get_direction(Vector2i(2, 0), fid), Vector2i(-1, 0), "3x3 (2,0)->W")
	ff.free_field(fid)


func _test_obstacle_unreachable(ff) -> void:
	# 3x1 row, target at (2,0), obstacle at (1,0) cuts off (0,0).
	# In a single-row grid there is no diagonal detour, so (0,0) is unreachable
	# and must report (0,0).
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(3, 1)))
	var obs := PackedByteArray([0, 1, 0])
	var fid: int = ff.compute_field(obs, [Vector2i(2, 0)])
	_eq(ff.get_direction(Vector2i(0, 0), fid), Vector2i.ZERO, "blocked (0,0) unreachable->(0,0)")
	_eq(ff.get_direction(Vector2i(2, 0), fid), Vector2i.ZERO, "blocked target->(0,0)")
	ff.free_field(fid)


func _test_multiple_targets(ff) -> void:
	# 5x1 row, targets at both ends (0,0) and (4,0). (2,0) is equidistant (cost
	# 20 to each). Direction selection is deterministic: the East neighbour (3,0)
	# is visited first in the 8-dir scan, so the result is (1,0).
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(5, 1)))
	var obs := PackedByteArray()
	obs.resize(5)
	var fid: int = ff.compute_field(obs, [Vector2i(0, 0), Vector2i(4, 0)])
	_eq(ff.get_direction(Vector2i(2, 0), fid), Vector2i(1, 0), "multi-target (2,0)->E")
	ff.free_field(fid)


func _test_target_cell_is_zero(ff) -> void:
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(3, 3)))
	var obs := PackedByteArray()
	obs.resize(9)
	var fid: int = ff.compute_field(obs, [Vector2i(1, 1)])
	_eq(ff.get_direction(Vector2i(1, 1), fid), Vector2i.ZERO, "target cell ->(0,0)")
	ff.free_field(fid)


func _test_out_of_bounds(ff) -> void:
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(3, 3)))
	var obs := PackedByteArray()
	obs.resize(9)
	var fid: int = ff.compute_field(obs, [Vector2i(0, 0)])
	_eq(ff.get_direction(Vector2i(9, 9), fid), Vector2i.ZERO, "out-of-bounds ->(0,0)")
	_eq(ff.get_direction(Vector2i(-1, 0), fid), Vector2i.ZERO, "negative cell ->(0,0)")
	ff.free_field(fid)


func _test_invalid_field_id(ff) -> void:
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(3, 3)))
	_eq(ff.get_direction(Vector2i(0, 0), 999999), Vector2i.ZERO, "invalid field id ->(0,0)")
	_eq(ff.get_direction(Vector2i(0, 0), -1), Vector2i.ZERO, "negative field id ->(0,0)")


func _test_free_field(ff) -> void:
	ff.configure(Rect2i(Vector2i.ZERO, Vector2i(5, 1)))
	var obs := PackedByteArray()
	obs.resize(5)
	var fid: int = ff.compute_field(obs, [Vector2i(4, 0)])
	# Before freeing, the direction resolves.
	_eq(ff.get_direction(Vector2i(0, 0), fid), Vector2i(1, 0), "pre-free resolves")
	ff.free_field(fid)
	# After freeing, the field is gone and must report (0,0).
	_eq(ff.get_direction(Vector2i(0, 0), fid), Vector2i.ZERO, "post-free ->(0,0)")


func _eq(actual: Vector2i, expected: Vector2i, label: String) -> void:
	if actual == expected:
		_passed += 1
	else:
		_fail("%s: expected %s, got %s" % [label, expected, actual])


func _fail(msg: String) -> void:
	_failed += 1
	push_error("FAIL: " + msg)
	print("FAIL: ", msg)


func _summary() -> void:
	print("flow_field_test: %d passed, %d failed" % [_passed, _failed])
