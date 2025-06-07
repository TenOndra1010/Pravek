extends Node

@onready var units_manager := get_parent().get_node("UnitsManager")
@onready var overworld := get_parent().get_node("Overworld")

var selected_unit: Unit = null
var unit_scenes := {}

func _ready():
	load_unit_scenes()
	start_game()

func load_unit_scenes():
	var dir := DirAccess.open("res://Units")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var path = "res://Units/" + file_name
				var packed_scene = load(path)
				if packed_scene is PackedScene:
					var instance = packed_scene.instantiate()
					if instance is Unit:
						var name = file_name.get_basename()
						unit_scenes[name] = packed_scene
						instance.queue_free()
			file_name = dir.get_next()

func start_game():
	spawn_unit("Unit", Vector2i(5, 5), "Player")
	spawn_unit("Unit", Vector2i(5, 10), "Player")
	spawn_unit("Unit", Vector2i(10, 5), "Player")
	spawn_unit("Unit", Vector2i(10, 10), "Gaia")
	
func _on_unit_selected(unit):
	if selected_unit:
		selected_unit.deselect()
	selected_unit = unit
	selected_unit.select()

func spawn_unit(unit_name: String, tile_coords: Vector2i, faction: String):
	if unit_scenes.has(unit_name):
		var unit = unit_scenes[unit_name].instantiate()
		unit.faction = faction
		unit.position = overworld.map_to_local(tile_coords)
		units_manager.add_unit(unit)
		unit.connect("unit_selected", Callable(self, "_on_unit_selected"))
