# Upon casting, this pattern will cause the caster to enter the level given by the supplied level_haver
static var iota_count = 1
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	if not entity.node is LevelHaver:
		stack.push_back(Bad_Iota.new())
		return "Error: entity is not a LevelHaver."
	hexecutor.main_scene.save_then_load_level(entity.node) # Level_haver is sent so it can be saved and updated later.
	hexecutor.scram_mode = true # Stop executing patterns
	return ""
		
