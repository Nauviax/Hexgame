# Turns an entity on the stack into it's position
static var descs = [
	"Given an entity, returns the tile position of the entity.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.get_fake_pos())
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	return true
