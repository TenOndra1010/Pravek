extends BaseTile

func _init():
	tile_name = "GrassTile"
	movement_cost = [1, 1, 1, 2]
	food_yield = [3, 3, 3, 0]
	production_yield = [1, 1, 1, 0]
	is_passable = [true, true, true, true]
	is_vision_blocking = [false, false, false, false]
	tileset_column_id = 1
