# Bool Sort level_logic

static func validate(level_base):
	var greens = level_base.entities_on_tile(4)
	if level_base.entities.size() - greens.size() > 1:
		return false # Instantly invalid if there are non-green entities (Excluding player, who is always on white)
	var trues = 0
	for entity in greens:
		var iota = entity.get_iota()
		if iota is bool and iota:
			trues += 1
		else:
			return false
	return trues == level_base.initiator.true_count # All trues are in the green area, and there are the right number of them