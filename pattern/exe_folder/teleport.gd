# Takes an entity (b) and a vector (a), then teleports the entity by the vector if the destination is an unblocked gate.
# This pattern does NOT require line of sight.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var vector = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	var pos = entity.get_fake_pos()
	var dest = round(pos + vector)
	var level = hexecutor.level_base # For functions
	if hexecutor.level_base.get_tile(dest, 1) == 1: # If gate
		if not level.entity_at(dest): # If no entity
			entity.set_fake_pos(dest)
		# No error if gate is blocked, should be visually obvious anyway.
	else:
		stack.push_back(Bad_Iota.new()) # DO error here, since it's less obvious. If your thoth is missing the gate, you'll want to know.
		return "Error: Destination did not lead to a gate"
	return ""
