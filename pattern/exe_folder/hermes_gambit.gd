# Remove a pattern or list of patterns from the stack, then cast them.
# Max depth 128.
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if list is Pattern: # Turn single pattern into list
		list = [list]
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list or pattern"
	for iota in list:
		if not iota is Pattern:
			stack.push_back(Bad_Iota.new())
			return "Error: List contained non-pattern iota"
			
	hexecutor.execution_depth += 1 # Prevent infinite recursion
	for pattern in list:
		var success = hexecutor.execute_pattern(pattern, false) # False means don't update display on pattern success
		if hexecutor.charon_mode:
			hexecutor.charon_mode = false
			hexecutor.execution_depth -= 1
			return "" # Stop execution
		if not success:
			hexecutor.execution_depth -= 1
			return null # No error message, no update. (Not success, so previous pattern already updated display.)
	hexecutor.execution_depth -= 1
	return ""