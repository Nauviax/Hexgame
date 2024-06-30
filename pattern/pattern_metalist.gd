class_name Pattern_Metalist

# List of patterns that make up this metalist
var patterns: Array = []

# Add a pattern to this metalist
# Special case for Retrospection, will instead complete the metalist.
# Special case for Evanition, will remove the last pattern added. (If list is empty, just complete list.)
func add_pattern(hexecutor: Hexecutor, pattern: Pattern) -> void: # Defined type
	if pattern.name_internal == Valid_Patterns.Pattern_Enum.introspection: # Nested metalist. Add as normal and increment depth
		hexecutor.introspection_depth += 1
		patterns.push_back(pattern)

	elif pattern.name_internal == Valid_Patterns.Pattern_Enum.retrospection: # End of metalist, check if we're still introspecting
		hexecutor.introspection_depth -= 1
		if hexecutor.introspection_depth > 0: # If still introspecting, just append and decrement
			patterns.push_back(pattern)
		else:
			hexecutor.stack.pop_back() # Remove this metalist from the stack
			hexecutor.stack.push_back(patterns) # Add patterns as list to stack

	elif pattern.name_internal == Valid_Patterns.Pattern_Enum.evanition: # Remove last pattern added
		if patterns.size() > 0:
			var removed: Pattern = patterns.pop_back()
			if removed.name_internal == Valid_Patterns.Pattern_Enum.introspection: # If removed pattern was introspection, decrement depth
				hexecutor.introspection_depth -= 1
			elif removed.name_internal == Valid_Patterns.Pattern_Enum.retrospection: # If removed pattern was retrospection, increment depth
				hexecutor.introspection_depth += 1
		else:
			hexecutor.introspection_depth = 0 # Stop introspection
			hexecutor.stack.pop_back() # Remove this metalist from the stack

	else:
		patterns.push_back(pattern)

# Show pattern names as a list, closing the [] only if complete
func _to_string() -> String:
	var result: String = "["
	for pattern: Pattern in patterns:
		result += str(pattern) + ", "
	return result