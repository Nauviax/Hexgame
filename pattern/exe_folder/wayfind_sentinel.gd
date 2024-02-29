# Takes a position, then returns a vector from the position to the caster's sentinel.
static var descs = [
	"Given a position, returns a vector from the position to the caster's sentinel. Fails if sentinel does not exist.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var sentinel_pos = hexecutor.caster.node.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_SENTINEL, pattern.name))
		return false
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", pos))
		return false
	var result = sentinel_pos - pos
	stack.push_back(result)
	hexecutor.caster.node.particle_target(Entity.fake_to_real(sentinel_pos)) # Particles
	hexecutor.caster.node.particle_trail(Entity.fake_to_real(pos), Entity.fake_to_real(result)) # Trail
	return true
