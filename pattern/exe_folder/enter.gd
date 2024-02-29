# Upon casting, this pattern will cause the caster to enter the level given by the supplied level_haver
static var descs = [
	"Given an entity that contains a level, will cause the caster to enter that level, leaving behind any stack and spellbook iotas for when they return.",
]
static var iota_count = 1
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "entity", entity))
		return false
	if not entity.node is LevelHaver:
		stack.push_back(Bad_Iota.new(ErrorMM.NOT_LEVEL_HAVER, pattern.name))
		return false
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles (Won't be seen until they return but ehhhh)
	hexecutor.main_scene.save_then_load_level(entity.node) # Level_haver is sent so it can be saved and updated later.
	hexecutor.scram_mode = true # Stop executing patterns
	return true
		
