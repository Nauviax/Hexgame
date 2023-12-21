# Takes a position (b) and a size (a), then deletes all entities within "size" tiles of the position (Square shape)
# Position is rounded to center on tile. Size can not be less than 1 (Will kill at least the neighbours)
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var size = stack.pop_back()
	if not size is float:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not float"
	if size < 1:
		stack.push_back(Bad_Iota.new())
		return "Error: Size must be at least 1"
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	pos = pos.round() # Round to center on tile and prevent cheese (No edge sniping single targets in group)
	var level_base = hexecutor.level_base
	var entities = level_base.entities
	var success = true
	for entity in entities:
		var entity_pos = entity.get_fake_pos() # pos and radius are in fake/tile space
		var distance = abs(entity_pos - pos) 
		if distance.x <= size and distance.y <= size:
			success = level_base.remove_entity(entity) and success # "and" so that success stays false on fail
	return "" if success else "Player death prevented" # Should be labled as a success by return handler
