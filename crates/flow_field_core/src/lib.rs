//! Engine-free 8-directional flow field pathfinder.
//!
//! Ported from the godot-cpp `FlowFieldPathfinder` plugin so pure Bevy sims
//! and the Godot/godot-bevy bridge share one algorithm. Legacy C++ GDExtension
//! remains available for existing Godot projects.

use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};

const DIR_DX: [i32; 8] = [0, 1, 1, 1, 0, -1, -1, -1];
const DIR_DY: [i32; 8] = [-1, -1, 0, 1, 1, 1, 0, -1];
const DIR_COST: [u16; 8] = [10, 14, 10, 14, 10, 14, 10, 14];
const DIR_NONE: u8 = 255;

#[derive(Clone, Debug)]
pub struct FlowField {
    pub width: i32,
    pub height: i32,
    pub distances: Vec<u16>,
    pub directions: Vec<u8>,
}

impl FlowField {
    fn cell_index(&self, x: i32, y: i32) -> usize {
        (y * self.width + x) as usize
    }

    /// Returns unit direction (dx, dy) toward lower cost, or (0,0) if none.
    pub fn direction(&self, x: i32, y: i32) -> (i32, i32) {
        if x < 0 || y < 0 || x >= self.width || y >= self.height {
            return (0, 0);
        }
        let dir = self.directions[self.cell_index(x, y)];
        if dir == DIR_NONE || (dir as usize) >= 8 {
            return (0, 0);
        }
        (DIR_DX[dir as usize], DIR_DY[dir as usize])
    }
}

/// Multi-field store matching the GDExtension API shape.
#[derive(Default, Debug)]
pub struct FlowFieldPathfinder {
    region_w: i32,
    region_h: i32,
    next_id: i64,
    fields: HashMap<i64, FlowField>,
}

impl FlowFieldPathfinder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn configure(&mut self, width: i32, height: i32) {
        self.region_w = width.max(0);
        self.region_h = height.max(0);
    }

    /// `obstacles` is row-major, non-zero = blocked. `targets` are goal cells.
    /// Returns field id.
    pub fn compute_field(&mut self, obstacles: &[u8], targets: &[(i32, i32)]) -> i64 {
        let w = self.region_w;
        let h = self.region_h;
        let total = (w * h).max(0) as usize;
        let mut field = FlowField {
            width: w,
            height: h,
            distances: vec![u16::MAX; total],
            directions: vec![DIR_NONE; total],
        };
        dijkstra(&mut field, obstacles, targets);
        compute_directions(&mut field);
        let id = self.next_id;
        self.next_id = self.next_id.saturating_add(1);
        self.fields.insert(id, field);
        id
    }

    pub fn get_direction(&self, x: i32, y: i32, field_id: i64) -> (i32, i32) {
        self.fields
            .get(&field_id)
            .map(|f| f.direction(x, y))
            .unwrap_or((0, 0))
    }

    pub fn free_field(&mut self, field_id: i64) {
        self.fields.remove(&field_id);
    }

    pub fn field(&self, field_id: i64) -> Option<&FlowField> {
        self.fields.get(&field_id)
    }
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct PqEntry {
    dist: u16,
    idx: usize,
}

impl Ord for PqEntry {
    fn cmp(&self, other: &Self) -> Ordering {
        // min-heap by dist
        other
            .dist
            .cmp(&self.dist)
            .then_with(|| self.idx.cmp(&other.idx))
    }
}

impl PartialOrd for PqEntry {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn dijkstra(field: &mut FlowField, obstacles: &[u8], targets: &[(i32, i32)]) {
    let w = field.width;
    let h = field.height;
    if w <= 0 || h <= 0 {
        return;
    }
    let mut pq = BinaryHeap::new();
    for &(tx, ty) in targets {
        if tx < 0 || ty < 0 || tx >= w || ty >= h {
            continue;
        }
        let idx = (ty * w + tx) as usize;
        field.distances[idx] = 0;
        pq.push(PqEntry { dist: 0, idx });
    }
    while let Some(PqEntry { dist, idx }) = pq.pop() {
        if dist != field.distances[idx] {
            continue;
        }
        let cx = (idx as i32) % w;
        let cy = (idx as i32) / w;
        for d in 0..8 {
            let nx = cx + DIR_DX[d];
            let ny = cy + DIR_DY[d];
            if nx < 0 || nx >= w || ny < 0 || ny >= h {
                continue;
            }
            let nidx = (ny * w + nx) as usize;
            if nidx < obstacles.len() && obstacles[nidx] != 0 {
                continue;
            }
            let ndist = dist.saturating_add(DIR_COST[d]);
            if ndist < field.distances[nidx] {
                field.distances[nidx] = ndist;
                pq.push(PqEntry {
                    dist: ndist,
                    idx: nidx,
                });
            }
        }
    }
}

fn compute_directions(field: &mut FlowField) {
    let w = field.width;
    let h = field.height;
    for y in 0..h {
        for x in 0..w {
            let idx = (y * w + x) as usize;
            let cur = field.distances[idx];
            if cur == u16::MAX || cur == 0 {
                field.directions[idx] = DIR_NONE;
                continue;
            }
            let mut best_dist = u16::MAX;
            let mut best_dir = DIR_NONE;
            for d in 0..8 {
                let nx = x + DIR_DX[d];
                let ny = y + DIR_DY[d];
                if nx < 0 || nx >= w || ny < 0 || ny >= h {
                    continue;
                }
                let nd = field.distances[(ny * w + nx) as usize];
                if nd < best_dist {
                    best_dist = nd;
                    best_dir = d as u8;
                }
            }
            field.directions[idx] = best_dir;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn flows_toward_target() {
        let mut ff = FlowFieldPathfinder::new();
        ff.configure(5, 5);
        let obstacles = vec![0u8; 25];
        let id = ff.compute_field(&obstacles, &[(4, 4)]);
        let (dx, dy) = ff.get_direction(0, 0, id);
        // Should step toward lower-right
        assert!(dx > 0 || dy > 0, "dir=({},{})", dx, dy);
        let (zx, zy) = ff.get_direction(4, 4, id);
        assert_eq!((zx, zy), (0, 0));
    }

    #[test]
    fn respects_obstacles() {
        let mut ff = FlowFieldPathfinder::new();
        ff.configure(3, 1);
        // block middle cell
        let obstacles = vec![0u8, 1, 0];
        let id = ff.compute_field(&obstacles, &[(2, 0)]);
        // cell 0 may still get a direction; blocked cell has no path from target through itself as open
        let d1 = ff.field(id).unwrap().distances[1];
        assert_eq!(d1, u16::MAX);
    }
}
