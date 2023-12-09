# Adds a trash iota to the stack
static var iota_count = 0
static func execute(hexlogic, pattern):
	hexlogic.stack.push_back(Bad_Iota.new())
	return "Error: Invalid pattern (" + pattern.p_code + ")"
