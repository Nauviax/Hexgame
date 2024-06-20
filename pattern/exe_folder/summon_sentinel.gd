# Summons/Moves the caster's sentinel to the given position
static var descs = [
	"Given a position, moves the caster's sentinel to that position. Creates a sentinel if one doesn't exist.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.log_spellbook_change(10) # Sentinel is changed
	var stack = hexecutor.stack
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", pos))
		return false
	hexecutor.caster.node.set_sentinel(pos)
	hexecutor.caster.node.particle_target(Entity.fake_to_real(pos)) # Particles
	return true
