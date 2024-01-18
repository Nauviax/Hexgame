class_name Entity
extends Resource # Should mean this object gets deleted automatically when not in use.

# Info regarding this entity, set on _init()
var name # Entity name, display and randomizer purposes
var node # Node/Object that this entity is attached to.
var look_dir = Vector2(0.0, -1.0) # Init just look up. (Normalized vector)
var alive = true # True if this entity is alive. (Equal to Node is not null)
# Dead entities return null for iota reads, and Vector2.ZERO for position reads.
# Any sets to dead entities are ignored, and no feedback is provided to the player.

# Generic readability and writeability for this entity when iota/sb is accessed externally. (Default neither)
var readable = false
var writeable = false

# Per-Entity variables that affect what spells affect them.
var killable = true # Explosion, Impulse into spikes
var moveable = true # Teleport, Impulse, Floating etc (set_pos and similar still function, this must be checked per spell!)

# True if this entity is floating. (Via Blue Sun's Nadir, Floating spell)
var is_floating = false

# Constructor
func _init(name, node):
	self.name = name
	self.node = node

# Returns the readable iota for this entity, if it exists.
# If the entity isn't readable, always returns null. No feedback to player provided. (They should audit to find out)
func get_iota():
	if readable and alive: # If readable and alive
		return node.get_iota() # If readable and this node doesn't have get_iota(), *something* bad will happen. Don't do that.
	else:
		return null

# Sets the currently selected iota in the spellbook.
# If the entity isn't writable, does nothing. No feedback to player provided. (They should audit to find out)
func set_iota(iota):
	if writeable and alive:
		node.set_iota(iota) # Same deal as get_iota()

# Display string for entity.
func _to_string():
	return "Entity: " + name + ("" if alive else " (Dead)")

# Position getters
func get_pos():
	if not alive: # Dead entity.
		return Vector2.ZERO
	return node.position

# (For display uses)
func get_fake_pos():
	if not alive: # Dead entity.
		return Vector2.ZERO
	return Entity.real_to_fake(node.position)

# Turns out setting fake pos is convenient when impulsing.
func set_fake_pos(pos):
	if alive:
		node.position = Entity.fake_to_real(pos)

# Velocity get (Returns 0,0 if no velocity var)
func get_fake_vel():
	if "velocity" in node and alive:
		return Entity.real_to_fake(node.velocity)
	else:
		return Vector2.ZERO # No velocity var, or dead entity.

# Death function. Deletes the entity node and cleans up.
# Should NOT be called through entity. Pass entity to level_base and delete via there.
func delete():
	alive = false # Set alive to false, so that other functions know this entity is dead.
	node.queue_free()
	node = null


# Coordinate conversions
# Fake takes 0,0 as centre of top left tile, but actual positions take 0,0 as top left CORNER
# Additionally, one tile is 64 pixels. so x64 to convert fake to real, /64 to convert real to fake
# Fake coordinates are for input/output, real coordinates are for mathing on and storing.

static var FAKE_SCALE = 64 # This val directly used by some patterns needing to convert fake distances to real distances. (Floats)

static func fake_to_real(level_pos: Vector2):
	return level_pos * FAKE_SCALE

static func real_to_fake(screen_pos: Vector2):
	return screen_pos / FAKE_SCALE
