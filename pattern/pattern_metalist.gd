class_name Pattern_Metalist

# List of patterns that make up this metalist
var patterns = []

# Add a pattern to this metalist
# Special case for Retrospection, will instead complete the metalist.
# Special case for Evanition, will remove the last pattern added. (If list is empty, just complete list.)
func add_pattern(hexlogic, pattern):
	if pattern.name == "Introspection": # Nested metalist. Add as normal and increment depth
		hexlogic.introspection_depth += 1
		patterns.push_back(pattern)

	elif pattern.name == "Retrospection": # End of metalist, check if we're still introspecting
		hexlogic.introspection_depth -= 1
		if hexlogic.introspection_depth > 0: # If still introspecting, just append and decrement
			patterns.push_back(pattern)
		else:
			hexlogic.stack.pop_back() # Remove this metalist from the stack
			hexlogic.stack.push_back(patterns) # Add patterns as list to stack

	elif pattern.name == "Evanition": # Remove last pattern added
		if patterns.size() > 0:
			patterns.pop_back()
		else:
			hexlogic.stack.pop_back() # Remove this metalist from the stack

	else:
		patterns.push_back(pattern)
	return ""

# Show pattern names as a list, closing the [] only if complete
func _to_string():
	var result = "["
	for pattern in patterns:
		result += str(pattern) + ", "
	return result