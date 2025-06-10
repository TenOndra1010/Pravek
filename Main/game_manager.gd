extends Node

@onready var units_manager := get_parent().get_node("UnitsManager")
@onready var overworld := get_parent().get_node("Overworld")
@onready var unit_actions := get_parent().get_node("UnitActions")

@export var season: int = 0

var selected_unit: Unit = null
var player_control_enabled := true

var factions: Dictionary = {}
var faction_order: Array = []
var current_faction_index := 0

var ai_turn_in_progress := false
var ai_units_to_process := []
var ai_current_unit_index := 0

var ai_action_delay := 0.5
var ai_action_timer := 0.0

func _ready():
	units_manager.load_unit_scenes()

func start_game():
	control_locked()
	create_faction("Player",true)
	create_faction("Deers",false)
	create_faction("Wolfs",false)
	spawn_unit("Human", Vector2i(5, 5), factions["Player"])
	spawn_unit("Human", Vector2i(5, 10), factions["Player"])
	spawn_unit("Deer", Vector2i(10, 5), factions["Deers"])
	spawn_unit("Wolf", Vector2i(10, 10), factions["Wolfs"])
	start_turn()
	control_unlocked()

func control_locked():
	player_control_enabled = false

func control_unlocked():
	player_control_enabled = true

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

	if current_faction.is_human:
		control_unlocked()
	else:
		# Prepare AI turn processing
		ai_turn_in_progress = true
		ai_units_to_process = current_faction.units.duplicate()
		ai_current_unit_index = 0
		control_locked()

func _process(delta):
	if ai_turn_in_progress:
		ai_action_timer -= delta
		if ai_action_timer <= 0:
			if ai_current_unit_index < ai_units_to_process.size():
				var unit = ai_units_to_process[ai_current_unit_index]
				unit.unit_ai_behaviour()  # Perform the unit's action
				ai_current_unit_index += 1
				
				ai_action_timer = ai_action_delay  # Reset delay timer
			else:
				# AI turn finished
				ai_turn_in_progress = false
				end_turn()

func end_turn():
	control_locked()
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
	if not units_manager.unit_scenes.has(unit_name):
		push_error("Unit scene '%s' not found!" % unit_name)
		return null
		
	var unit = units_manager.unit_scenes[unit_name].instantiate()
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
	
func kill_unit(unit: Unit):
	if not is_instance_valid(unit):
		push_warning("Attempted to kill an invalid or already freed unit.")
		return

	# Remove unit from its tile
	var tile = overworld.get_logical_tile(unit.tile_position)
	if tile:
		tile.remove_unit(unit)

	# Remove unit from faction
	if unit.faction:
		unit.faction.remove_unit(unit)

	# Deselect if it's the selected unit
	if unit == selected_unit:
		deselect_current_unit()

	# Remove unit from units manager
	units_manager.remove_unit(unit)

	# Disconnect any signals if necessary (optional, mostly safe to skip if freeing immediately)
	unit.disconnect("unit_selected", Callable(self, "_on_unit_selected"))

	# Free the unit node
	unit.queue_free()

	print("Unit '%s' was killed and removed from the game." % unit.unit_name)

	

func _unhandled_input(event):
	if not player_control_enabled:
		return
	
	if event.is_action_pressed("end_turn"):
		end_turn()
		return
	
	if not selected_unit or not is_instance_valid(selected_unit):
		return
	if selected_unit.faction.turn_index != current_faction_index:
		return
	#if selected_unit.is_moving:
	#	return
	if not event.is_pressed():
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
		var target_tile_coords = selected_unit.tile_position + direction
		var target_tile = overworld.get_logical_tile(target_tile_coords)
		
		if target_tile:
			if target_tile.has_enemy_unit(selected_unit.faction):
				print("Enemy unit detected at ", target_tile_coords)
				if selected_unit.attack > 0:
					var target_array: Array = target_tile.get_enemy_units(selected_unit.faction)
					control_locked()
					unit_actions.engage_combat(selected_unit, target_array[0], direction)
					control_unlocked()
			else:
				unit_actions.move_unit(selected_unit, target_tile_coords)
