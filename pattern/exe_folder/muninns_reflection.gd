# Copy the iota out of the caster's ravenmind.
static var iota_count = 0
static func execute(hexlogic, _pattern):
	hexlogic.stack.push_back(hexlogic.caster.ravenmind)
	return ""