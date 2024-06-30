# Reveal Iota level_logic

static func validate(level_base: Level_Base) -> bool:
	var goal_iota: Variant = level_base.initiator.iota
	if typeof(goal_iota) != typeof(level_base.revealed_iota):
		return false # Ensure same type before comparing
	return level_base.revealed_iota == goal_iota