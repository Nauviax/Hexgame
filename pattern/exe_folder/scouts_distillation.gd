# Takes a position (b) and a direction (a) and returns the ENTITY hit by the raycast, or null if none is found.
# If the raycast hits a wall, returns null.
static var iota_count = 2
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var dir = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	dir = dir.normalized()
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base = hexecutor.level_base # Used to do raycasting
	stack.push_back(level_base.entity_raycast(pos, dir)) # Return entity
	return ""
