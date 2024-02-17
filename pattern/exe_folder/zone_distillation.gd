# Take a position (second-top) and max distance (top), then combine them into a list of all entities near the position.
# Result is sorted by distance, closest entity (The caster normally) being index 0.
# Max distance is capped at 5 tiles. (Prevent getting every entity on map) Position can be any distance away.
static var descs = [
	"Given a position (SECOND) and a distance (TOP), returns a list of all entities within that distance of the position.",
	"The list is sorted by distance, with the closest entity being the first element. Distance from position is capped at 5 tiles.",
]
static var iota_count = 2
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var dst = stack.pop_back()
	if not dst is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", dst))
		return false
	if dst < 0 or dst > 5:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, 5, dst))
		return false
	dst = Entity.FAKE_SCALE * dst # Convert to real distance
	var pos = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var entities = hexecutor.level_base.entities
	var result_unsorted = []
	for entity in entities:
		var dist = (entity.get_pos() - pos).length()
		if dist <= dst:
			result_unsorted.append([entity, dist])
	stack.push_back(dist_sort(result_unsorted))
	return true

# Takes a result_unsorted list and returns a list of just sorted entities
# Sort determines which entity is further, using the second element of the list.
static func dist_sort(unsorted: Array):
	unsorted.sort_custom(func(aa, bb): return aa[1] < bb[1])
	return unsorted.map(func(item): return item[0])
