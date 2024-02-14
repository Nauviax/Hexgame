# Takes a position (b) and a direction (a) and returns the tile hit by the raycast.
# Tile position is returned in fake coordinates, representing the centre of the tile hit. (Or null if no tile was hit)
# Raycast distance should be 16 tiles.
static var descs = [
	"Given a position (SECOND) and a direction (TOP), returns the centre tile coordinates hit by a raycast, or null if no hit. Max distance 16 tiles. Ignores glass and entities.",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var dir = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", dir))
		return false
	dir = dir.normalized()
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base = hexecutor.level_base # Used to do raycasting
	stack.push_back(level_base.block_raycast(pos, dir)) # Return fake coords of tile hit
	return true