# Sets the caster's selected spellbook page to num (top of stack)
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a number"
	var caster = hexlogic.caster
	var size = caster.sb.size()
	if num < 0 or num >= size:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was out of bounds"
	caster.sb_sel = int(num)
	return ""