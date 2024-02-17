# Adds the numerical pattern value to the stack
static var descs = [
	"Represents and returns a number, determined by the exact pattern drawn. See next page for more.",
	"Draw initial diamond clockwise for negative, counter for positive. Then for each possible direction left to right: L = x2, l = 5, s = 1, r = 10, R = /2."
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	hexecutor.stack.push_back(pattern.value)
	return true
