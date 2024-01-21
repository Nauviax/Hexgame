# Remove an entity iota, and pushes the entitie's iota. (Or entity's spellbook selected iota)
# Always returns <null> if the entity can't be read from externally.
static var iota_count = 1
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an entity"
	stack.push_back(entity.get_iota())
	return ""