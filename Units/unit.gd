extends Node2D

class_name Unit

@export var tile_position: Vector2i
@export var unit_type: String = "Unit"
@export var faction: String
@export var unit_name: String = "TestUnit"
@export var maxhealth: int = 3
@export var health: int
@export var attack: int = 1
@export var defense: int = 1
@export var move_speed: float = 200.0
@export var is_active: bool = true

var is_selected := false
signal unit_selected(unit)
var is_moving := false
var target_world_position: Vector2
var game_manager: Node = null

func set_game_manager(manager: Node):
	game_manager = manager

func _ready():
	if health > maxhealth:
		health = maxhealth
	$Area2D.input_pickable = true
	$Area2D.connect("input_event", Callable(self, "_on_area_2d_input_event"))
	deselect()
		
func debug_info():
	print("Unit Spawned: %s (%s)" % [unit_name, faction])
	
func get_combat_stats() -> Dictionary:
	return {
		"attack": attack,
		"defense": defense,
		"health": health,
		"maxhealth": maxhealth
	}
	
func select():
	is_selected = true
	$SelectionIndicator.visible = true

func deselect():
	is_selected = false
	$SelectionIndicator.visible = false
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and faction == "Player":
			emit_signal("unit_selected", self)
			
func move_to(tile_coords: Vector2i):
	target_world_position = game_manager.tile_to_world(tile_coords)
	is_moving = true

func _physics_process(delta):
	if is_moving:
		var distance = target_world_position - position
		var step = move_speed * delta

		if distance.length() <= step:
			position = target_world_position
			is_moving = false
		else:
			position += distance.normalized() * step
