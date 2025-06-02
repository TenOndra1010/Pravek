extends TileMap

const MAP_WIDTH := 50
const MAP_HEIGHT := 80

# IDs of the tiles you want to randomly use
# Format: (source_id, atlas_coords)
var tile_options := [
	Vector2i(0, 0), # Tile A (atlas coordinates)
	Vector2i(1, 0), # Tile B
	Vector2i(2, 0), # Tile C
]

const TILE_SOURCE_ID := 0

func _ready():
	generate_random_map()

func generate_random_map():
	randomize()

	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			var tile_coords:Vector2i = tile_options[randi() % tile_options.size()]
			set_cell(0, Vector2i(x, y), TILE_SOURCE_ID, tile_coords)
