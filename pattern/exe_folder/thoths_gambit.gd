# Remove a list of patterns (bb) and a list (aa) from the stack, then cast the given pattern over each element of the second list.
# More specifically, for each element in the second list, it will:
# - Create a new stack, with everything on the current stack plus that element
# - Draw all the patterns in the first list
# - Save all the iotas remaining on the stack to a list
# Then, after all is said and done, pushes the list of saved iotas onto the main stack.

# Order of saving to results list is tip to tail, with bottom of first (first = list[0] iota) stack being the first element.

static var iota_count = 2
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "list", list))
		return false
	var patterns = stack.pop_back()
	if not patterns is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "list", patterns))
		return false
	for ii in range(patterns.size()):
		if not patterns[ii] is Pattern:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name, 0, "pattern", ii, patterns[ii]))
			return false
	
	hexecutor.execution_depth += 1 # Prevent infinite recursion (!!! Should this be 8 or smth to reduce recursion for thoths?)
	var results = [] # List of results from each list iota. 
	var hexecutor2 = Hexecutor.new(hexecutor.level_base, hexecutor.caster, hexecutor.main_scene, false) # New hexecutor for meta execution (New stack)
	# Note this hexecutor takes "false" as a fourth argument, which among other things means it will not update the display.
	hexecutor2.execution_depth = hexecutor.execution_depth # Execution depth persist to prevent infinite recursion

	for iota in list:
		hexecutor2.stack = stack.duplicate(true) # Copy stack (Deep copy)
		hexecutor2.stack.push_back(iota) # Load 
		for next_pattern in patterns:
			var success = hexecutor2.execute_pattern(next_pattern, false) # False means don't update display on pattern success
			if hexecutor2.charon_mode or not success:
				# Leave charon mode set true, as we won't be returning to this hexecutor anyway. Safer to leave true.
				break # Stop executing patterns for this iota
		
		results.append_array(hexecutor2.stack) # Append leftover stack to results
		hexecutor2.reset(true) # Clean up, don't reset ravenmind
		if hexecutor2.charon_mode:
			break # Don't execute any more list iotas

	# Note to self, execution depth should be equal at this point, so copying it is redundant. (That's the idea anyway.)
	hexecutor.execution_depth -= 1
	stack.push_back(results) # Push results
	return true
