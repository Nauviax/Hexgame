# Removes the caster's sentinel.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.caster.node.set_sentinel(null)
	return ""
