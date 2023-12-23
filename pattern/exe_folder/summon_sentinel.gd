# Summons/Moves the caster's sentinel to the given position
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	hexecutor.caster.set_sentinel(pos)
	return ""
