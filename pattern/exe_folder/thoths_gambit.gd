# Remove a list of patterns (b) and a list (a) from the stack, then cast the given pattern over each element of the second list.
# More specifically, for each element in the second list, it will:
# - Create a new stack, with everything on the current stack plus that element
# - Draw all the patterns in the first list
# - Save all the iotas remaining on the stack to a list
# Then, after all is said and done, pushes the list of saved iotas onto the main stack.

# Order of saving to results list is tip to tail, with bottom of first (first = list[0] iota) stack being the first element.

static var iota_count = 2
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	var patterns = stack.pop_back()
	if not patterns is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	for iota in patterns:
		if not iota is Pattern:
			stack.push_back(Bad_Iota.new())
			return "Error: List contained non-pattern iota"
	
	hexlogic.execution_depth += 1 # Prevent infinite recursion (!!! Should this be 8 or smth to reduce recursion for thoths? !!!)
	var results = [] # List of results from each list iota. 
	var hexecutor2 = Hexecutor.new(hexlogic.level_info, hexlogic.caster) # New hexecutor for meta execution (New stack)
	hexecutor2.execution_depth = hexlogic.execution_depth # Execution depth persist to prevent infinite recursion

	for iota in list:
		hexecutor2.stack = [iota] # Load 
		for pattern in patterns:
			var success = hexecutor2.execute_pattern(pattern, false) # False means don't update display on pattern success
			if hexecutor2.charon_mode or not success:
				# Leave charon mode set true, as we won't be returning to this hexecutor anyway. Safer to leave true.
				break # Stop executing patterns for this iota
		
		results.append_array(hexecutor2.stack) # Append leftover stack to results
		hexecutor2.reset(true) # Clean up
		if hexecutor2.charon_mode:
			break # Don't execute any more list iotas

	# Note to self, execution depth should be equal at this point, so copying it is redundant. (That's the idea anyway.)
	hexlogic.execution_depth -= 1
	stack.push_back(results) # Push results
	return ""
