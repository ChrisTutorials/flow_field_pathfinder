# Bevy Rust direction

Canonical engine-free crate: **`moonbark_flow_field`** in
`MoonBark-Studio/moonbark-bevy`.

This plugin keeps:

1. `crates/flow_field_core` — pure Rust port of the C++ algorithm
2. `cpp/` — **legacy** godot-cpp GDExtension (unchanged for existing Godot builds)

New Bevy / godot-bevy work should depend on `moonbark_flow_field`.
The C++ GDExtension remains supported until consumers migrate.
