extends Camera2D

@export var move_speed := 300.0

var zoom_levels := [Vector2(5, 5), Vector2(4, 4), Vector2(3, 3)]
var zoom_index := 0

func _ready():
	zoom = zoom_levels[zoom_index]

func _process(delta):
	handle_movement(delta)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if Input.is_action_pressed("zoom_in"):
			change_zoom(-1)
		elif Input.is_action_pressed("zoom_out"):
			change_zoom(1)

func handle_movement(delta):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1

	position += input_vector.normalized() * move_speed * delta

func change_zoom(direction: int):
	zoom_index = clamp(zoom_index + direction, 0, zoom_levels.size() - 1)
	zoom = zoom_levels[zoom_index]
