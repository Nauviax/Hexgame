# Push true if the specified entity's spellbook can be read from externally, false otherwise.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not an entity"
	stack.push_back(entity.sb_read)
	return ""