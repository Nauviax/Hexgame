# Remove an entity iota, and pushes the entity's iota. (Or entity's spellbook selected iota)
# Always returns <null> if the entity can't be read from externally.
static var descs = [
	"Given an entity iota, returns a copy of the iota contained in the entity. If the entity isn't readable for any reason, returns null.",
	"If given a player entity, the iota is copied from the player's selected spellbook page"
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	stack.push_back(entity.get_iota())
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true