# Upon casting, this pattern will cause the caster to unload and exit the level.
# Returns Bad_Iota if there is no level to exit to.
# Takes the caster as an iota, to help prevent accidental use.
static var iota_count = 1
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var caster = stack.pop_back()
	if not caster is Entity or caster != hexecutor.caster:
		stack.push_back(Bad_Iota.new())
		return "Error: Exit requires the caster as an iota."
	hexecutor.main_scene.exit_level()
	hexecutor.scram_mode = true # Stop executing patterns
	return ""
