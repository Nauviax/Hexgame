# Take a position, then return the first friendly entity at that position (Dist < 0.5)																																																																																																																																																																																																											)
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	pos = Entity.fake_to_real(pos) # Convert to real position
	var entities = hexecutor.level_info.entities
	for entity in entities:
		if not entity.team == 0:
			continue 
		if entity.get_pos().x == pos.x and entity.get_pos().y == pos.y:
			stack.push_back(entity)
			return ""
	stack.push_back(null) # If no entity found
	return ""