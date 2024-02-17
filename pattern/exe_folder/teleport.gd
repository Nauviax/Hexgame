# Takes an entity (b) and a vector (a), then teleports the entity by the vector if the destination is an unblocked gate.
# This pattern can teleport through glass, but not through walls.
static var descs = [
	"Given an entity (SECOND) and a vector (TOP), teleports the entity by the given vector offset. Will fail if destination is not a gate, or the gate is blocked.",
	"Must be a moveable entity. No max distance. Can teleport through glass, but not through walls."
]
static var iota_count = 2
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var vector = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", vector))
		return false
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "entity", entity))
		return false
	if not entity.moveable: # If can't move entity, just return silently
		return true
	var pos = entity.get_fake_pos()
	var dest = round(pos + vector)
	var level_base = hexecutor.level_base # For functions
	if hexecutor.level_base.get_tile_id(dest, 1) == 22: # If gate
		if not level_base.entity_at(dest): # If no entity
			# Ensure line of sight
			# (Unnormalized vector + false value, which will create shorter raycasts. (Equal to vector length))
			var hit = level_base.block_raycast(pos * Entity.FAKE_SCALE, vector * Entity.FAKE_SCALE, false)
			if hit == null: # No blocks in way
				entity.set_fake_pos(dest)
		# No error if gate is blocked or not in sight, should be visually obvious anyway.
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_GATE, pattern.name, vector, dest)) # DO error here, since it's less obvious. If your thoth is missing the gate, you'll want to know.
		return false
	return true

