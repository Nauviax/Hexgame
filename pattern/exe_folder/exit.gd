# Upon casting, this pattern will cause the caster to unload and exit the level.
# Returns Bad_Iota if there is no level to exit to.
# Takes the caster as an iota, to help prevent accidental use.
static var iota_count = 1
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var caster = stack.pop_back()
	if not caster is Entity or caster != hexecutor.caster:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity (player)", caster))
		return false
	hexecutor.main_scene.exit_level()
	hexecutor.scram_mode = true # Stop executing patterns
	return true
