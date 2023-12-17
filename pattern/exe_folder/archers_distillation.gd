# Takes a position (b) and a direction (a) and returns the tile hit by the raycast.
# Tile position is returned in fake coordinates, representing the centre of the tile hit. (Or null if no tile was hit)
# Raycast distance should be 16 tiles.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var dir = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	dir = dir.normalized()
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base = hexecutor.level_base # Used to do raycasting
	stack.push_back(level_base.block_raycast(pos, dir)) # Return fake coords of tile hit
	return ""