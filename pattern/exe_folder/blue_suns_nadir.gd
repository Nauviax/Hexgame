# Takes an entity, then gives them floating for their next impulse.
# Also allows player entities to fly.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	entity.is_floating = entity.moveable # If the entity is moveable, then float them.
	return ""