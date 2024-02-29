# Take a position, then return the first entity at that position
static var descs = [
	"Given a vector, returns the entity at that position vector, or null if no entity is found. Must exactly match entity position.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var entities = hexecutor.level_base.entities
	for entity in entities:
		if entity.get_pos().x == pos.x and entity.get_pos().y == pos.y:
			stack.push_back(entity)
			hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
			return true
	stack.push_back(null) # If no entity found
	return true