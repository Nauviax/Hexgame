# For a vector, coerce it to its nearest axial direction, a unit vector.
# For a number, return the sign of the number; 1 if positive, -1 if negative.
# In both cases, zero is unaffected.
static var iota_count = 1
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var iota = stack.pop_back()
	if iota is float:
		if iota > 0:
			stack.push_back(1.0)
		elif iota < 0:
			stack.push_back(-1.0)
		else:
			stack.push_back(0.0)
	elif iota is Vector2:
		var unitVector = Vector2(0, 0) # Default 0,0 if x == y == 0
		var xx = iota.x
		var yy = iota.y
		if xx == 0 and yy == 0:
			stack.push_back(unitVector) # Just push 0,0.
			return ""
		if xx > yy:
			unitVector.x = 1 if iota.x > 0 else -1
		elif xx <= yy: # On tie, y wins.
			unitVector.y = 1 if iota.y > 0 else -1
		stack.push_back(unitVector)
	else:
		stack.push_back(Bad_Iota.new())
		return "Error: Invalid iota type"
	return ""
