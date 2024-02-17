# Remove a pattern or list of patterns from the stack, then cast them.
# Max depth 128.
static var descs = [
	"Given a pattern or list of patterns, will cast them in order as if they were casted manually. Max depth is 128.",
]
static var iota_count = 1
static var is_spell = true # If this pattern changes the level in any way. (Meta pattern assume true, as can be either)
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if list is Pattern: # Turn single pattern into list
		list = [list]
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "pattern/list", list))
		return false
	for ii in range(list.size()):
		if not list[ii] is Pattern:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name, 0, "pattern", ii, list[ii]))
			return false
			
	hexecutor.execution_depth += 1 # Prevent infinite recursion
	for next_pattern in list:
		var success = hexecutor.execute_pattern(next_pattern, false) # False means don't update display on pattern success
		if hexecutor.charon_mode:
			hexecutor.charon_mode = false
			hexecutor.execution_depth -= 1
			return true # Stop execution
		if not success:
			hexecutor.execution_depth -= 1
			return false # End early
	hexecutor.execution_depth -= 1
	return true