extends Node

@onready var units_manager := get_parent().get_node("UnitsManager")
@onready var overworld := get_parent().get_node("Overworld")
@onready var unit_actions = get_parent().get_node("UnitActions")

@export var season: int = 0

var selected_unit: Unit = null
var unit_scenes := {}

var factions: Dictionary = {}
var faction_order: Array = []
var current_faction_index := 0

func _ready():
	load_unit_scenes()

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
	create_faction("Player",true)
	create_faction("Gaia",false)
	spawn_unit("Unit", Vector2i(5, 5), factions["Player"])
	spawn_unit("Unit", Vector2i(5, 10), factions["Player"])
	spawn_unit("Unit", Vector2i(10, 5), factions["Player"])
	spawn_unit("Unit", Vector2i(10, 10), factions["Gaia"])
	start_turn()

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return overworld.local_to_map(world_pos)

func tile_to_world(tile_coords: Vector2i) -> Vector2:
	return overworld.map_to_local(tile_coords)

func get_unit_tile(unit):
	var tile_coords = unit.tile_position
	return overworld.get_logical_tile(tile_coords)

func create_faction(faction_name: String, is_human: bool):
	if factions.has(faction_name):
		push_warning("Faction '%s' already registered!" % faction_name)
		return
	
	var new_faction = Faction.new()
	new_faction.faction_name = faction_name
	new_faction.is_human = is_human
	new_faction.turn_index = faction_order.size()
	
	factions[faction_name] = new_faction
	faction_order.append(faction_name)
	print("Faction '%s' registered and initialized." % faction_name)
	
func start_turn():
	var current_faction_name = faction_order[current_faction_index]
	var current_faction = factions[current_faction_name]
	print("Turn started for: %s" % current_faction_name)
	current_faction.reset_units_ap()

func end_turn():
	current_faction_index = (current_faction_index + 1) % faction_order.size()
	deselect_current_unit()
	start_turn()

func deselect_current_unit():
	if selected_unit:
		selected_unit.deselect()
		selected_unit = null

func _on_unit_selected(unit):
	if selected_unit:
		selected_unit.deselect()
	selected_unit = unit
	selected_unit.select()
	
	var tile = get_unit_tile(selected_unit)
	
	if tile:
		print("Selected unit '%s' on tile type: %s at %s" % [selected_unit.unit_name, tile.tile_type.tile_name, selected_unit.tile_position])

func spawn_unit(unit_name: String, tile_coords: Vector2i, faction: Faction):
	if not unit_scenes.has(unit_name):
		push_error("Unit scene '%s' not found!" % unit_name)
		return null
		
	var unit = unit_scenes[unit_name].instantiate()
	unit.faction = faction
	unit.tile_position = tile_coords
	unit.position = tile_to_world(tile_coords)
	
	units_manager.add_unit(unit)
	faction.add_unit(unit)
	unit.set_game_manager(self)
	
	var tile = overworld.get_logical_tile(tile_coords)
	if tile:
		tile.add_unit(unit)
		print("Spawned unit '%s' on tile type: %s at %s" % [unit_name, tile.tile_type.tile_name, tile_coords])
	else:
		push_warning("Logical tile at %s not found." % tile_coords)

	unit.connect("unit_selected", Callable(self, "_on_unit_selected"))

func _unhandled_input(event):
	if event.is_action_pressed("end_turn"):
		end_turn()
		return
	
	if not selected_unit or not is_instance_valid(selected_unit):
		return
	if not event.is_pressed():
		return
	if selected_unit.is_moving:
		return
		
	var direction := Vector2i.ZERO
	
	if Input.is_action_pressed("unit_left"):
		direction = Vector2i.LEFT
	elif Input.is_action_pressed("unit_right"):
		direction = Vector2i.RIGHT
	elif Input.is_action_pressed("unit_up"):
		direction = Vector2i.UP
	elif Input.is_action_pressed("unit_down"):
		direction = Vector2i.DOWN

	if direction != Vector2i.ZERO:
		unit_actions.move_unit(selected_unit, selected_unit.tile_position + direction)
