# Take a position (second-top) and max distance (top), then combine them into a list of all entities near the position.
# Result is sorted by distance, closest entity (The caster normally) being index 0.
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
	var result_unsorted = []
	for entity in entities:
		var dist = (entity.get_pos() - pos).length()
		if dist <= dst:
			result_unsorted.append([entity, dist])
	stack.push_back(dist_sort(result_unsorted))
	return ""

# Takes a result_unsorted list and returns a list of just sorted entities
# Sort determines which entity is further, using the second element of the list.
static func dist_sort(unsorted: Array):
	unsorted.sort_custom(func(aa, bb): return aa[1] < bb[1])
	return unsorted.map(func(item): return item[0])
