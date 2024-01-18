# Copy the iota out of the caster's ravenmind.
static var iota_count = 0
static func execute(hexecutor, _pattern):
	hexecutor.stack.push_back(hexecutor.caster.node.ravenmind)
	return ""