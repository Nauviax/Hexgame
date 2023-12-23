# Reveal Iota Validator
static var desc = "Reveal Iota: Simply obtain and reveal the iota stored in the haver. (Remember to hit validate afterwards!)"
static func validate(level_base):
	var goal_iota = level_base.randomizer.iota
	if typeof(goal_iota) != typeof(level_base.revealed_iota):
		return false # Ensure same type before comparing
	return level_base.revealed_iota == goal_iota