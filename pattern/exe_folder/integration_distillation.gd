# Remove the top of the stack, then add it to the end of the list at the top of the stack.
static var descs = [
	"Given an iota (TOP) and a list (SECOND), returns the list with the iota appended to the end.",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", list))
		return false
	list.push_back(iota)
	stack.push_back(list)
	return true