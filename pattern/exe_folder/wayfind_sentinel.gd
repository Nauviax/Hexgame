# Takes a position, then returns a vector from the position to the caster's sentinel.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var sentinel_pos = hexecutor.caster.node.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new())
		return "Error: No sentinel position set"
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	stack.push_back(sentinel_pos - pos)
	return ""
