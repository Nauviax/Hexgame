# Takes the modulus of two numbers. (5 % 3 is 2)
# When applied on vectors, performs the above operation elementwise
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(fmod(bb, aa))
	elif aa is Vector2 and bb is Vector2:
		bb.x = fmod(bb.x, aa.x)
		bb.y = fmod(bb.y, aa.y)
		stack.push_back(bb)
	elif aa is float and bb is Vector2:
		bb.x = fmod(bb.x, aa)
		bb.y = fmod(bb.y, aa)
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true
