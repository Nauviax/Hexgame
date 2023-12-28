# Upon casting, this pattern will cause the caster to enter the level given by the supplied level_haver
static var iota_count = 1
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var level_haver = stack.pop_back()
	if not level_haver is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	if not level_haver.ravenmind is PackedScene:
		stack.push_back(Bad_Iota.new())
		return "Error: entity does not contain a level."
	hexecutor.main_scene.save_then_load_level(level_haver) # Level_haver is sent so it can be saved and updated later.
	hexecutor.scram_mode = true # Stop executing patterns
	return ""
		
