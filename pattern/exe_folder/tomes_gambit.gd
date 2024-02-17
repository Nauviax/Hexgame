# Sets the caster's selected spellbook page to num (top of stack)
static var descs = [
	"Given a number, sets the caster's selected spellbook page to that number.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	var player = hexecutor.caster.node
	var size = player.sb.size() # Should be 4 always, but just in case I change it later.
	if num < 0 or num >= size:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, size-1, num))
		return false
	player.sb_sel = int(num)
	return true