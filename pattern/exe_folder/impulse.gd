# Takes an entity (b) and a vector (a), then pushes the entity in the given direction by the vector magnitude. (Max magnitude is 16)
# If entity is floating, does NOT collide with spikes.
static var descs = [
	"Given an entity (SECOND) and a vector (TOP), pushes the entity in the given direction by the vector magnitude.",
	"Must be a moveable entity. Max magnitude is 16. Entities that aren't floating will collide with spikes and die."
]
static var iota_count = 2
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var vector = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "vector", vector))
		return false
	var length = vector.length()
	if length > 16:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, "length 0", "length 16", "length " + str(length)))
		return false
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 1, "entity", entity))
		return false
	if (not entity.moveable) or (length < 0.1): # If can't move entity, or distance is ~0, just return silently
		return true
	var pos_real = entity.get_pos() # Actual pos (For raycasting)
	var pos = Entity.real_to_fake(pos_real) # Fake pos (For interpolation)
	var level_base = hexecutor.level_base # Used to do raycasting
	var target = level_base.impulse_raycast(pos_real, vector * Entity.FAKE_SCALE, entity.is_floating) # Return point of tile hit (or max dist)
	var interpolated = interpolated_line(pos, target) # Slightly short
	for tile in interpolated: # Should start at furthest tile and work backwards, due to order of list.
		if level_base.entity_at(tile): # Entity check (The actually important check)
			continue 
		if (not entity.is_floating) and level_base.get_tile_id(tile, 1) == 21: # Spike check
			var dead = level_base.remove_entity(entity) # Attempt to push poor entity into spikes
			if dead:
				return true # Woo
			else:
				continue # Player can't be killed, so keep looking for safe spot.
		var tile_id = level_base.get_tile_id(tile, 0)
		if tile_id == 1 or tile_id == 2: # Wall/Glass check
			continue # Can't land here, nope.
		if tile_id == 0: # Out of Bounds check (Regardless of is_floating)
			if level_base.remove_entity(entity): # Attempt to push poor entity out of map
				return true # Woo
			# Else, if not dead, still set pos. See what happens. (Likely the player, and will respawn)
		var old_pos = entity.get_pos() # REAL coords, used for particles
		entity.set_fake_pos(tile)
		entity.is_floating = false # Clear floating status (Irrelevant if entity is not floating)
		hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
		hexecutor.caster.node.particle_trail(old_pos, Entity.fake_to_real(vector)) # Old pos to desired location, NOT current location.
		return true
	entity.is_floating = false # Still clear floating status
	return true # Just don't impulse

# Returns a set of points from p1 to p0 using linear interpolation
static func interpolated_line(p0, p1):
	var points = []
	var dp = p1 - p0
	var l_dist = roundi(max(abs(dp.x), abs(dp.y)))
	if l_dist == 0:
		return [] # Prevent returning (nan, nan) points and sending entity to shadow realm
	for ii in l_dist + 1: 
		var tt = float(ii) / l_dist
		points.append(lerp(p1, p0, tt).round())
	return points
