# Placeholder (!!!)
static var iota_count = 1
static func execute(hexlogic, _pattern):
	var stack = hexlogic.stack
	var list = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not a list"
	for iota in list:
		if not iota is Pattern:
			stack.push_back(Bad_Iota.new())
			return "Error: List contained non-pattern iota"
	for pattern in list:
		var success = hexlogic.execute_pattern(pattern, false) # False means don't update display on pattern success
		if not success:
			return "Error: A pattern failed to run"
	return ""

