# With two numbers, combines them by raising bb to the power of aa. (aa is top of stack)
# With a number and a vector, raises each component of the vector to the number's power.
# With two vectors, combines them into the vector projection of aa onto bb.
static var descs = [
	"Given two numbers, raises the SECOND number to the power of the TOP number.",
	"Given a number (TOP) and a vector (SECOND), raises each component of the vector to the power of the number.",
	"Given two vectors, returns the vector projection of the TOP vector onto the SECOND vector."
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(bb ** aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back(aa.project(bb))
	elif aa is float and bb is Vector2:
		bb.x = bb.x ** aa
		bb.y = bb.y ** aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true