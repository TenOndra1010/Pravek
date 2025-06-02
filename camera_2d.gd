extends Camera2D

@export var base_speed := 1000.0

var zoom_levels := [Vector2(4, 4), Vector2(3, 3), Vector2(2, 2)]
var zoom_index := 0
var move_speed := base_speed

func _ready():
	apply_zoom()

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
	apply_zoom()

func apply_zoom():
	zoom = zoom_levels[zoom_index]
	move_speed = base_speed / zoom.x
