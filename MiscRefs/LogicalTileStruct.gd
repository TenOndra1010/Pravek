extends Node
class_name LogicalTileStruct

@export var tile_coords: Vector2i
@export var tile_type: BaseTile
@export var present_units: Array[Unit] = []

var map_node

func set_map_node(the_map_node: Node) -> void:
	map_node = the_map_node

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

func get_adjacent_attack_power(unit_type_filter: String, faction_filter: Faction = null) -> int:

	var total_attack_power := 0
	
	# Only true neighbours: up, down, left, right
	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]

	for dir in directions:
		var adj_pos = tile_coords + dir
		var adj_tile = map_node.get_logical_tile(adj_pos)
		if adj_tile == null:
			continue
		
		for unit in adj_tile.get_units():
			if unit.unit_type == unit_type_filter and (faction_filter == null or unit.faction == faction_filter):
				total_attack_power += unit.attack
	
	return total_attack_power
