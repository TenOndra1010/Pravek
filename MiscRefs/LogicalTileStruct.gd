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
	return present_units.duplicate()

func has_unit_with_faction(faction: Faction) -> bool:
	for unit in present_units:
		if unit.faction == faction:
			return true
	return false

func has_enemy_unit(faction: Faction) -> bool:
	for unit in present_units:
		if unit.faction != faction:
			return true
	return false

func get_enemy_units(faction: Faction) -> Array:
	var enemies := []
	for unit in present_units:
		if unit.faction != faction:
			enemies.append(unit)
	return enemies
