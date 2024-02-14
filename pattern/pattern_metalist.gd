class_name Pattern_Metalist

# List of patterns that make up this metalist
var patterns = []

# Add a pattern to this metalist
# Special case for Retrospection, will instead complete the metalist.
# Special case for Evanition, will remove the last pattern added. (If list is empty, just complete list.)
func add_pattern(hexecutor: Hexecutor, pattern: Pattern): # Defined type
	if pattern.name == "Introspection": # Nested metalist. Add as normal and increment depth
		hexecutor.introspection_depth += 1
		patterns.push_back(pattern)

	elif pattern.name == "Retrospection": # End of metalist, check if we're still introspecting
		hexecutor.introspection_depth -= 1
		if hexecutor.introspection_depth > 0: # If still introspecting, just append and decrement
			patterns.push_back(pattern)
		else:
			hexecutor.stack.pop_back() # Remove this metalist from the stack
			hexecutor.stack.push_back(patterns) # Add patterns as list to stack

	elif pattern.name == "Evanition": # Remove last pattern added
		if patterns.size() > 0:
			patterns.pop_back()
		else:
			hexecutor.introspection_depth = 0 # Stop introspection
			hexecutor.stack.pop_back() # Remove this metalist from the stack

	else:
		patterns.push_back(pattern)

# Show pattern names as a list, closing the [] only if complete
func _to_string():
	var result = "["
	for pattern in patterns:
		result += str(pattern) + ", "
	return result