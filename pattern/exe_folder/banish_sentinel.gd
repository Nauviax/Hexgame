# Removes the caster's sentinel.
static var iota_count = 0
static var is_spell = false # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.caster.node.set_sentinel(null)
	return true
