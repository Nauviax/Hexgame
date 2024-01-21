# Turns an entity on the stack into it's position
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.get_fake_pos())
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not an entity"
	return ""
