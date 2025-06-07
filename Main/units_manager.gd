extends Node

var units: Array = []

func _ready():
	_update_units_list()

func _update_units_list():
	units.clear()
	for child in get_children():
		units.append(child)

func add_unit(unit: Node2D) -> void:
	if not units.has(unit):
		units.append(unit)
		add_child(unit)

func remove_unit(unit: Node2D) -> void:
	if units.has(unit):
		units.erase(unit)
		unit.queue_free()

func get_units_by_faction(faction: String) -> Array:
	return units.filter(func(u): return u.faction == faction)

func get_all_units() -> Array:
	return units.duplicate()
