# Takes an entity, then gives them floating for their next impulse. Will remove floating if they already have it.
# Also allows player entities to fly.
static var iota_count = 1
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	if entity.is_floating:
		entity.is_floating = false # Remove floating if they already have it.
	else:
		entity.is_floating = entity.moveable # If the entity is moveable, then float them.
	return ""