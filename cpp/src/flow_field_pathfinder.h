#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/variant/rect2i.hpp>

#include <cstdint>
#include <unordered_map>
#include <vector>

using namespace godot;

class FlowFieldPathfinder : public RefCounted {
	GDCLASS(FlowFieldPathfinder, RefCounted);

	struct Field {
		int width;
		int height;
		std::vector<uint16_t> distances;
		std::vector<uint8_t> directions;
	};

	Vector2i _region_size;
	int _next_field_id = 0;
	std::unordered_map<int, Field> _fields;

	static const int8_t DIR_DX[8];
	static const int8_t DIR_DY[8];
	static const uint16_t DIR_COST[8];
	static constexpr uint8_t DIR_NONE = 255;

	void _dijkstra(Field &field, const PackedByteArray &p_obstacles,
		       const TypedArray<Vector2i> &p_targets);
	void _compute_directions(Field &field);
	int _cell_index(int x, int y, int width) const;

protected:
	static void _bind_methods();

public:
	void configure(Rect2i p_region);
	int64_t compute_field(PackedByteArray p_obstacles,
			      TypedArray<Vector2i> p_targets);
	Vector2i get_direction(Vector2i p_cell, int64_t p_field_id);
	void free_field(int64_t p_field_id);
};
