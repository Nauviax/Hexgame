# Turns an entity on the stack into it's velocity (Tiles per second hopefully)
static var descs = [
	"Given an entity, returns it's velocity vector. Most of the time, this will be (0,0).",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.get_fake_vel())
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	return true
