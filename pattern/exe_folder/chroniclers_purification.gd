# Remove an entity iota, and pushes the iota from the entity's selected spellbook page.
# Always returns <null> if the entity can't be read from externally.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an entity"
	stack.push_back(entity.get_iota())
	return ""