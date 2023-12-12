# Remove a pattern or list of patterns from the stack, then cast them.
# Max depth 128.
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
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
	hexlogic.execution_depth += 1 # Prevent infinite recursion
	for pattern in list:
		var success = hexlogic.execute_pattern(pattern, false) # False means don't update display on pattern success
		if not success:
			hexlogic.execution_depth -= 1
			return null # No error message, no update.
	hexlogic.execution_depth -= 1
	return ""