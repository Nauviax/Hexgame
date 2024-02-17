# Reverse the list at the top of the stack.
static var descs = [
	"Given a list, returns a new list with the elements in reverse order.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	list.reverse()
	stack.push_back(list)
	return true
