# Sets the caster's selected spellbook page to num (top of stack)
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var player = hexecutor.caster.node
	var size = player.sb.size()
	if num < 0 or num >= size:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was out of bounds"
	player.sb_sel = int(num)
	return ""