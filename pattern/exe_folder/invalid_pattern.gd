# Adds a trash iota to the stack
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.INVALID_PATTERN, pattern.name, pattern.p_code))
	return false
