# Test Level Validator
static var desc = "Test Level: All entities on green tiles must contain true. At least one on-green entity must exist."
static func validate(level_base):
	var green_entities = []
	var entities = level_base.entities
	for entity in entities:
		var pos = entity.get_fake_pos()
		var tile = level_base.get_tile_id(pos, 0)
		if tile == 4:
			green_entities.append(entity)
	if green_entities.size() == 0:
		return false # Instantly invalid if empty
	for entity in green_entities:
		var iota = entity.sb[entity.sb_sel]
		if not (iota is bool and iota):
			return false
	return true