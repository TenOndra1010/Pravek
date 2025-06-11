extends Node2D

@onready var overworld := $Overworld
@onready var game_manager := $GameManager

func _ready():
	overworld.generate_logical_map()
	overworld.draw_map()
	game_manager.start_game()
