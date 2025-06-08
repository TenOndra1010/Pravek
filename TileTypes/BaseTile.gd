extends Resource
class_name BaseTile

@export var tile_name: String = "BaseTile"

# Movement cost per season: [spring, summer, autumn, winter]
@export var movement_cost: Array[int] = [1, 1, 1, 1]

# Food yield per season
@export var food_yield: Array[int] = [0, 0, 0, 0]

# Production yield per season
@export var production_yield: Array[int] = [0, 0, 0, 0]

# Whether the tile is passable in each season
@export var is_passable: Array[bool] = [false, false, false, false]

# Whether the tile blocks vision in each season
@export var is_vision_blocking: Array[bool] = [false, false, false, false]

# Column index in the tileset for rendering
@export var tileset_column_id: int = 1

func get_movement_cost(season_index: int) -> int:
	season_index = clamp(season_index, 0, movement_cost.size() - 1)
	return movement_cost[season_index]

func get_food_yield(season_index: int) -> int:
	season_index = clamp(season_index, 0, food_yield.size() - 1)
	return food_yield[season_index]

func get_production_yield(season_index: int) -> int:
	season_index = clamp(season_index, 0, production_yield.size() - 1)
	return production_yield[season_index]	

func is_tile_passable(season_index: int) -> bool:
	season_index = clamp(season_index, 0, is_passable.size() - 1)
	return is_passable[season_index]

func is_tile_vision_blocking(season_index: int) -> bool:
	season_index = clamp(season_index, 0, is_vision_blocking.size() - 1)
	return is_vision_blocking[season_index]
