# Turns an entity on the stack into the direction it's looking
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.look_dir)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Iota was not an entity"
	return ""
