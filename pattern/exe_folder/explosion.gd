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
	var close_entities = []
	for entity in entities:
		var entity_pos = entity.get_fake_pos() # pos and radius are in fake/tile space
		var distance = abs(entity_pos - pos) 
		if distance.x <= size and distance.y <= size:
			close_entities.push_back(entity)
	if hexecutor.caster in close_entities: # Error if caster is in explosion radius (Even though it wouldn't be removed)
		stack.push_back(Bad_Iota.new())
		return "Error: Caster in explosion radius"
	for entity in close_entities:
		level_base.remove_entity(entity) # Will not remove unkillable entities
	return ""
