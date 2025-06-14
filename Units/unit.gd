extends Node2D

class_name Unit

@export var tile_position: Vector2i
@export var unit_type: String = "Unit"
@export var faction: Faction
@export var unit_name: String = "Man"
@export var max_ap: int = 10
@export var ap: int = 10
@export var attack: int = 1
@export var defense: int = 1
@export var move_speed: float = 200.0
@export var breeding_rate = 0

signal unit_selected(unit)

var is_selected := false
var is_moving := false
var target_world_position: Vector2
var game_manager: Node = null
var move_queue: Array[Vector2i] = []

func set_game_manager(manager: Node):
	game_manager = manager

func _ready():
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", Callable(self, "_on_area_2d_input_event"))
	deselect()
	reset_ap()

func debug_info():
	print("Unit Spawned: %s (%s)" % [unit_name, faction])

func get_combat_stats() -> Dictionary:
	return {
		"attack": attack,
		"defense": defense,
	}

func select():
	is_selected = true
	$SelectionIndicator.visible = true

func deselect():
	is_selected = false
	$SelectionIndicator.visible = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and game_manager.player_control_enabled:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("unit_selected", self)

# === AP Management ===

func reset_ap():
	ap = max_ap

func has_ap(required_ap := 1) -> bool:
	return ap >= required_ap

func use_ap(amount := 1):
	if ap >= amount:
		ap -= amount
		print("Used AP:")
		print(amount)
		print("AP left:")
		print(ap)
	else:
		push_warning("Tried to use more AP than available!")

# === Movement ===

func move_to(tile_coords: Vector2i):
	target_world_position = game_manager.tile_to_world(tile_coords)
	is_moving = true

func unit_ai_behaviour():
	return
	
func breed():
	return

func _physics_process(delta):
	if is_moving:
		var distance = target_world_position - position
		var step = move_speed * delta

		if distance.length() <= step:
			position = target_world_position
			is_moving = false
		else:
			position += distance.normalized() * step
	elif move_queue.size() > 0:
		var next_tile = move_queue.pop_front()
		target_world_position = game_manager.tile_to_world(next_tile)
		is_moving = true

func clear_movement_queue():
	move_queue.clear()
	is_moving = false
