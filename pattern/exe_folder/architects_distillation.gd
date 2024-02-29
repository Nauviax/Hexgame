# Takes a position (b) and a direction (a) and returns the SIDE of the tile hit by the raycast, or null if none is found.
# If this hits the south face of a tile, it would return (0, 1) 
static var descs = [
	"Given a position (SECOND) and a direction (TOP), returns the normal of the tile hit by a raycast, or null if no tile was hit. Max distance 16 tiles. Ignores glass and entities.",
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
	var results = level_base.block_side_raycast(pos, dir)
	if results:
		stack.push_back(results[0]) # Return normal of tile hit
		hexecutor.caster.node.particle_target(results[1])
		hexecutor.caster.node.particle_trail(pos, results[1] - pos)
	else:
		stack.push_back(null) # No tile hit
		hexecutor.caster.node.particle_trail(pos, dir * Entity.FAKE_SCALE) # Raycast distance 1 tile
	return true
