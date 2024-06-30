# Test Level level_logic

static func validate(level_base: Level_Base) -> bool:
	var greens: Array = level_base.entities_on_tile(4)
	if greens.size() == 0:
		return false # Instantly invalid if empty
	for entity: Entity in greens:
		var iota: Variant = entity.get_iota()
		if not (iota is bool and iota):
			return false
	return true