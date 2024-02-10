# Takes the top two iotas in stack, returns the sum
# For Arrays, appends list aa to the end of list bb
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var aa = stack.pop_back()
	var bb = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(aa + bb)
	elif aa is Vector2 and bb is Vector2:
		aa += bb
		stack.push_back(aa)
	elif aa is float and bb is Vector2:
		bb.x += aa
		bb.y += aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		aa.x += bb
		aa.y += bb
		stack.push_back(aa)
	elif aa is Array and bb is Array:
		bb += aa
		stack.push_back(bb)
	elif aa is Array and bb is Vector2:
		bb.append(aa)
		stack.push_back(bb)
	elif aa is Vector2 and bb is Array:
		aa.append(bb)
		stack.push_back(aa)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name, aa, bb))
		return false
	return true
