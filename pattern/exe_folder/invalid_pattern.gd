# Adds a trash iota to the stack
static var descs = [
	"Created when no defined functionality is tied to the given pattern. Will return an error if cast.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.INVALID_PATTERN, pattern.name, pattern.p_code))
	return false
