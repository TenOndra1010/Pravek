extends BaseTile

func _init():
	tile_name = "ForestTile"
	movement_cost = [2, 2, 2, 3]
	food_yield = [2, 2, 2, 0]
	production_yield = [3, 3, 3, 2]
	is_passable = [true, true, true, true]
	is_vision_blocking = [true, true, true, true]
	tileset_column_id = 2
