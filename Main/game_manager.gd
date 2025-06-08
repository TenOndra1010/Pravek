extends Node

@onready var units_manager := get_parent().get_node("UnitsManager")
@onready var overworld := get_parent().get_node("Overworld")

var selected_unit: Unit = null
var unit_scenes := {}

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
	spawn_unit("Unit", Vector2i(5, 5), "Player")
	spawn_unit("Unit", Vector2i(5, 10), "Player")
	spawn_unit("Unit", Vector2i(10, 5), "Player")
	spawn_unit("Unit", Vector2i(10, 10), "Gaia")
	
func world_to_tile(world_pos: Vector2) -> Vector2i:
	return overworld.local_to_map(world_pos)
	
func tile_to_world(tile_coords: Vector2i) -> Vector2:
	return overworld.map_to_local(tile_coords)
	
func get_unit_tile(unit):
	var tile_coords = unit.tile_position
	return overworld.get_logical_tile(tile_coords)
	
func _on_unit_selected(unit):
	if selected_unit:
		selected_unit.deselect()
	selected_unit = unit
	selected_unit.select()

	var tile = get_unit_tile(selected_unit)

	if tile:
		print("Selected unit '%s' on tile type: %s at %s" % [selected_unit.unit_name, tile.tile_type.tile_name, selected_unit.tile_position])

func spawn_unit(unit_name: String, tile_coords: Vector2i, faction: String):
	if not unit_scenes.has(unit_name):
		push_error("Unit scene '%s' not found!" % unit_name)
		return null

	var unit = unit_scenes[unit_name].instantiate()
	unit.faction = faction
	unit.tile_position = tile_coords  # <-- FIXED HERE
	unit.position = tile_to_world(tile_coords)

	units_manager.add_unit(unit)
	unit.set_game_manager(self)

	var tile = overworld.get_logical_tile(tile_coords)
	if tile:
		tile.add_unit(unit)
		print("Spawned unit '%s' on tile type: %s at %s" % [unit_name, tile.tile_type.tile_name, tile_coords])
	else:
		push_warning("Logical tile at %s not found." % tile_coords)

	unit.connect("unit_selected", Callable(self, "_on_unit_selected"))
	
func _unhandled_input(event):
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
		unit_movement_handler(selected_unit, selected_unit.tile_position + direction)

func check_move_validity(target_tile):
	var target_logical_tile = overworld.get_logical_tile(target_tile)
	print(target_logical_tile.tile_type.tile_name)
	print(target_logical_tile.tile_type.is_tile_passable(0))
	return target_logical_tile.tile_type.is_tile_passable(0)

func unit_movement_handler(unit, new_tile):
	if check_move_validity(new_tile):
		var new_logical_tile = overworld.get_logical_tile(new_tile)
		if new_logical_tile:
			var old_tile = overworld.get_logical_tile(unit.tile_position)
			if old_tile:
				old_tile.remove_unit(unit)
			new_logical_tile.add_unit(unit)

			unit.tile_position = new_tile
			unit.move_to(new_tile)
