# Takes the inverse tangent of a Y (aa) and X (bb) value,
# Yielding the angle between the X-axis and a line from the origin to that point. (!!! Should this be a vector?)
static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	var bb = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "number", bb))
		return false
	var result = atan2(aa, bb)
	stack.push_back(result)
	return true