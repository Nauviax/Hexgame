# Remove the first iota from the list at the top of the stack, then push that iota to the stack.
static var descs = [
	"Given a list, removes the first iota from it and returns the iota and the resulting list to the stack. Iota above list.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	var iota = list.pop_front()
	stack.push_back(list)
	stack.push_back(iota)
	return true