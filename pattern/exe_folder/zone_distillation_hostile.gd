# Take a position (second-top) and max distance (top), then combine them into a list of hostile entities near the position.
static var iota_count = 2
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var dst = stack.pop_back()
	var pos = stack.pop_back()
	if not dst is float or not pos is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: invalid iota type recieved"
	pos = Entity.fake_to_real(pos) # Convert to real position
	dst = Entity.FAKE_SCALE * dst # Convert to real distance
	var entities = hexecutor.level_base.entities
	var result = []
	for entity in entities:
		if not entity.team == -1:
			continue
		var dist = (entity.get_pos() - pos).length()
		if dist <= dst:
			result.append(entity)
	stack.push_back(result)
	return ""