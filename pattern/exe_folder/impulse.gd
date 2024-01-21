# Takes an entity (b) and a vector (a), then pushes the entity in the given direction by the vector magnitude. (Max magnitude is 16)
# If entity is floating, does NOT collide with spikes.
static var iota_count = 2
static var is_spell = true # If this pattern interacts with the level in any way.
static func execute(hexecutor, _pattern):
	var stack = hexecutor.stack
	var vector = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not vector"
	var length = vector.length()
	if length > 16 or length < 0.1:
		stack.push_back(Bad_Iota.new())
		return "Error: vector length was too large or invalid"
	var entity = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new())
		return "Error: iota was not entity"
	if not entity.moveable: # If can't move entity, just return silently
		return ""
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
				return "" # Woo
			else:
				continue # Player can't be killed, so keep looking for safe spot.
		var tile_id = level_base.get_tile_id(tile, 0)
		if tile_id == 1 or tile_id == 2: # Wall/Glass check
			continue # Can't land here, nope.
		if tile_id == 0: # Out of Bounds check (Regardless of is_floating)
			if level_base.remove_entity(entity): # Attempt to push poor entity out of map
				return "" # Woo
			# If not dead, still set pos. See what happens. (Likely the player, and will respawn)
		entity.set_fake_pos(tile)
		entity.is_floating = false # Clear floating status (Irrelevant if entity is not floating)
		return ""
	entity.is_floating = false # Still clear floating status
	return "" # Just don't impulse

# Returns a set of points from p1 to p0 using linear interpolation
static func interpolated_line(p0, p1):
	var points = []
	var dp = p1 - p0
	var l_dist = roundi(max(abs(dp.x), abs(dp.y)))
	for ii in l_dist + 1: 
		var tt = float(ii) / l_dist
		points.append(lerp(p1, p0, tt).round())
	return points
