# Adds a random number between 0 and 1, rounded to 2 decimal places, to the stack.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(randi_range(0, 99) / 100.0)
	return ""