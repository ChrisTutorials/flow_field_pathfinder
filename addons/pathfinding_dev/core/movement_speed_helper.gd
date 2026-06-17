class_name MovementSpeedHelper
extends RefCounted

## Resolves effective movement speed.
##
## Games override this helper or inject a callback to apply
## upgrade modifiers, status effects, or environment debuffs.

signal speed_resolved(base_speed: float, effective_speed: float)

## Default implementation returns the base speed unchanged.
static func resolve(base_speed: float, entity: Object = null) -> float:
    return base_speed
