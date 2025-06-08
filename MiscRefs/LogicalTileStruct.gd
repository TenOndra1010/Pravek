extends Node
class_name LogicalTileStruct

@export var tile_coords: Vector2i
@export var tile_type: BaseTile
@export var present_units: Array[Unit] = []

func add_unit(unit: Unit) -> void:
	if unit not in present_units:
		present_units.append(unit)

func remove_unit(unit: Unit) -> void:
	if unit in present_units:
		present_units.erase(unit)

func has_unit(unit: Unit) -> bool:
	return unit in present_units

func clear_units() -> void:
	present_units.clear()

func get_unit_count() -> int:
	return present_units.size()

func get_units() -> Array[Unit]:
	return present_units.duplicate()  # Return a copy for safety
