# Remove the top iota from the stack, then an entity, and save the iota to the entity. (Or entity's selected spellbook page.)
# Fails silently if the entity can't be written to externally.
static var iota_count = 2
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	entity.set_iota(iota)
	return true