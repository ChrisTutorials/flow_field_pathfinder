#include "flow_field_pathfinder.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <queue>
#include <utility>

using namespace godot;

// 8-directional vectors: N, NE, E, SE, S, SW, W, NW
const int8_t FlowFieldPathfinder::DIR_DX[8] = {  0,  1,  1,  1,  0, -1, -1, -1 };
const int8_t FlowFieldPathfinder::DIR_DY[8] = { -1, -1,  0,  1,  1,  1,  0, -1 };
const uint16_t FlowFieldPathfinder::DIR_COST[8] = { 10, 14, 10, 14, 10, 14, 10, 14 };

void FlowFieldPathfinder::_bind_methods() {
	ClassDB::bind_method(D_METHOD("configure", "region"),
			     &FlowFieldPathfinder::configure);
	ClassDB::bind_method(D_METHOD("compute_field", "obstacles", "targets"),
			     &FlowFieldPathfinder::compute_field);
	ClassDB::bind_method(D_METHOD("get_direction", "cell", "field_id"),
			     &FlowFieldPathfinder::get_direction);
	ClassDB::bind_method(D_METHOD("free_field", "field_id"),
			     &FlowFieldPathfinder::free_field);
}

int FlowFieldPathfinder::_cell_index(int x, int y, int width) const {
	return y * width + x;
}

void FlowFieldPathfinder::configure(Rect2i p_region) {
	_region_size = p_region.get_size();
}

int64_t FlowFieldPathfinder::compute_field(PackedByteArray p_obstacles,
					   TypedArray<Vector2i> p_targets) {
	const int w = _region_size.x;
	const int h = _region_size.y;
	const int total_cells = w * h;

	Field field;
	field.width = w;
	field.height = h;
	field.distances.assign(total_cells, UINT16_MAX);
	field.directions.assign(total_cells, DIR_NONE);

	_dijkstra(field, p_obstacles, p_targets);
	_compute_directions(field);

	const int id = _next_field_id++;
	_fields[id] = std::move(field);
	return id;
}

void FlowFieldPathfinder::_dijkstra(Field &field,
				    const PackedByteArray &p_obstacles,
				    const TypedArray<Vector2i> &p_targets) {
	const int w = field.width;
	const int h = field.height;
	const uint8_t *obstacles = p_obstacles.ptr();
	const int obstacle_count = p_obstacles.size();

	using PQEntry = std::pair<uint16_t, int>;
	std::priority_queue<PQEntry, std::vector<PQEntry>,
			    std::greater<PQEntry>> pq;

	for (int i = 0; i < p_targets.size(); i++) {
		const Vector2i t = p_targets[i];
		if (t.x < 0 || t.x >= w || t.y < 0 || t.y >= h)
			continue;
		const int idx = _cell_index(t.x, t.y, w);
		field.distances[idx] = 0;
		pq.emplace(0, idx);
	}

	while (!pq.empty()) {
		auto [dist, idx] = pq.top();
		pq.pop();

		if (dist != field.distances[idx])
			continue;

		const int cx = idx % w;
		const int cy = idx / w;

		for (int d = 0; d < 8; d++) {
			const int nx = cx + DIR_DX[d];
			const int ny = cy + DIR_DY[d];
			if (nx < 0 || nx >= w || ny < 0 || ny >= h)
				continue;

			const int nidx = _cell_index(nx, ny, w);

			if (nidx < obstacle_count && obstacles[nidx])
				continue;

			const uint16_t ndist = dist + DIR_COST[d];
			if (ndist < field.distances[nidx]) {
				field.distances[nidx] = ndist;
				pq.emplace(ndist, nidx);
			}
		}
	}
}

void FlowFieldPathfinder::_compute_directions(Field &field) {
	const int w = field.width;
	const int h = field.height;

	for (int y = 0; y < h; y++) {
		for (int x = 0; x < w; x++) {
			const int idx = _cell_index(x, y, w);
			const uint16_t cur = field.distances[idx];

			if (cur == UINT16_MAX || cur == 0) {
				field.directions[idx] = DIR_NONE;
				continue;
			}

			uint16_t best_dist = UINT16_MAX;
			uint8_t best_dir = DIR_NONE;

			for (int d = 0; d < 8; d++) {
				const int nx = x + DIR_DX[d];
				const int ny = y + DIR_DY[d];
				if (nx < 0 || nx >= w || ny < 0 || ny >= h)
					continue;

				const uint16_t nd = field.distances[_cell_index(nx, ny, w)];
				if (nd < best_dist) {
					best_dist = nd;
					best_dir = static_cast<uint8_t>(d);
				}
			}

			field.directions[idx] = best_dir;
		}
	}
}

Vector2i FlowFieldPathfinder::get_direction(Vector2i p_cell,
					    int64_t p_field_id) {
	auto it = _fields.find(static_cast<int>(p_field_id));
	if (it == _fields.end())
		return Vector2i(0, 0);

	const Field &field = it->second;
	if (p_cell.x < 0 || p_cell.x >= field.width ||
	    p_cell.y < 0 || p_cell.y >= field.height)
		return Vector2i(0, 0);

	const int idx = _cell_index(p_cell.x, p_cell.y, field.width);
	const uint8_t dir = field.directions[idx];

	if (dir == DIR_NONE)
		return Vector2i(0, 0);

	return Vector2i(DIR_DX[dir], DIR_DY[dir]);
}

void FlowFieldPathfinder::free_field(int64_t p_field_id) {
	_fields.erase(static_cast<int>(p_field_id));
}
