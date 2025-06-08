extends BaseTile

func _init():
	tile_name = "WaterTile"
	movement_cost = [2, 2, 2, 2]
	food_yield = [2, 3, 3, 0]
	production_yield = [0, 0, 0, 0]
	is_passable = [false, false, false, true]
	is_vision_blocking = [false, false, false, false]
	tileset_column_id = 0
