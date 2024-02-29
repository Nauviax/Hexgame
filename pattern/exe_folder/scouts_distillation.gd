# Takes a position (b) and a direction (a) and returns the ENTITY hit by the raycast, or null if none is found.
# If the raycast hits a wall, returns null.
static var descs = [
	"Given a position (SECOND) and a direction (TOP), returns the entity hit by a raycast, or null if no entity was hit. Max distance 16 tiles. Ignores glass, but NOT walls.",
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
	var entity = level_base.entity_raycast(pos, dir)
	stack.push_back(entity) # Return entity
	# Particles
	if entity:
		var entity_pos = entity.get_pos()
		hexecutor.caster.node.particle_target(entity_pos)
		hexecutor.caster.node.particle_trail(pos, entity_pos - pos)
	else:
		hexecutor.caster.node.particle_trail(pos, dir * Entity.FAKE_SCALE) # Raycast distance 1 tile
	return true
