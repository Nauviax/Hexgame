# Takes a position (b) and a size (a), then deletes all entities within "size" tiles of the position (Square shape)
# Position is rounded to center on tile. Size can not be less than 1 (Will kill at least the neighbours)
static var iota_count = 2
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var size = stack.pop_back()
	if not size is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", size))
		return false
	if size < 1:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 1, "any", size))
		return false
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "vector", pos))
		return false
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
		stack.push_back(Bad_Iota.new(ErrorMM.CASTER_IN_RANGE, pattern.name))
		return false
	for entity in close_entities:
		level_base.remove_entity(entity) # Will not remove unkillable entities
	return true
