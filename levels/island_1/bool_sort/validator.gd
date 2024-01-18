# Bool Sort Validator
static var desc = "Bool Sort: Move any haver containing true to the green area. Kill any haver containing false. You cannot write to the havers."
static func validate(level_base):
	var greens = []
	var non_greens = []
	var entities = level_base.entities
	for entity in entities:
		var pos = entity.get_fake_pos()
		var tile = level_base.get_tile_id(pos, 0)
		if tile == 4:
			greens.append(entity)
		else:
			non_greens.append(entity)
	if non_greens.size() > 1:
		return false # Instantly invalid if there are non-green entities (Excluding player, who is always on white)
	for entity in greens:
		var iota = entity.get_iota()
		if not (iota is bool and iota):
			return false
	return true