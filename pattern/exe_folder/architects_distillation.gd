# Takes a position (b) and a direction (a) and returns the SIDE of the tile hit by the raycast, or null if none is found.
# If this hits the south face of a tile, it would return (0, 1) 
static var iota_count = 2
static var is_spell = true # If this pattern interacts with the level in any way.
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
	stack.push_back(level_base.block_side_raycast(pos, dir)) # Return normal of tile hit
	return true
