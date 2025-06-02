extends TileMap

const MAP_WIDTH := 100
const MAP_HEIGHT := 60

const WATER_THRESHOLD := 0.25
const FOREST_THRESHOLD := 0.4

const TILE_SOURCE_ID := 0

# Tile atlas coordinates
const WATER_TILE := Vector2i(0, 0)
const GRASS_TILE := Vector2i(1, 0)
const FOREST_TILE := Vector2i(2, 0)

var noise := FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.05
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 4

	generate_random_map()

func generate_random_map():
	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			var value := noise.get_noise_2d(x, y)
			value = (value + 1.0) / 2.0

			var atlas_coords := GRASS_TILE
			if value < WATER_THRESHOLD:
				atlas_coords = WATER_TILE
			elif value > FOREST_THRESHOLD:
				atlas_coords = FOREST_TILE

			set_cell(0, Vector2i(x, y), TILE_SOURCE_ID, atlas_coords)
