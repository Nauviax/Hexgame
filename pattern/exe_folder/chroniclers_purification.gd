# Remove an entity iota, and pushes the entity's iota. (Or entity's spellbook selected iota)
# Always returns <null> if the entity can't be read from externally.
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	stack.push_back(entity.get_iota())
	return true