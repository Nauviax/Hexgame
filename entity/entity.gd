class_name Entity
extends Resource # Should mean this object gets deleted automatically when not in use.

# Info regarding this entity, set on _init()
var name # Entity name, display and randomizer purposes
var node # Node/Object that this entity is attached to.
var look_dir # (1.0, 0.0), normalized vector

var sb = [null] # List of iotas that this entity is storing.
var sb_names = ["0"] # List of names of iotas in spellbook, for display purposes. (!!! Maybe remove for now?)
var sb_sel = 0 # Index of currently selected iota in spellbook.
var sb_read = true # True if other entities can read from this entity's spellbook. (Selected iota only)
var sb_write = true # True if other entities can write to this entity's spellbook. (Selected iota only)
# Spellbook size should be fixed, so no push/pop, just set/get. (Unless specifically trying to expand/shrink spellbook size)
# For external reading/writing, use provided get/set functions.

 # True if this entity is floating. (Via Blue Sun's Nadir, Floating spell)
var is_floating = false

# Ravenmind iota. Not readable/writable by other entities, and lost on grid clear (Assuming this entity can cast)
var ravenmind = null 

# Sentinel_pos vector. Preserved on grid clear.
# THIS IS A FAKE/TILE POSITION
var sentinel_pos = null

# Constructor (Set look_dir later)
func _init(name, node):
	self.name = name
	self.node = node

# Sets values for spellbook. Mainly for setting sb_read/write, but can also be used to set spellbook size / default values.
func set_spellbook(sb_read, sb_write, sb:Array, gen_names = true):
	self.sb_read = sb_read
	self.sb_write = sb_write
	self.sb = sb
	if gen_names:
		self.sb_names = []
		for ii in range(len(sb)):
			self.sb_names.append(str(ii)) # ["0", "1", "2", ...] as needed

# Returns the currently selected iota in the spellbook.
# If the entity isn't readable, always returns null. No feedback to player provided. (They should audit to find out)
func get_iota():
	if sb_read:
		return sb[sb_sel]
	else:
		return null

# Sets the currently selected iota in the spellbook.
# If the entity isn't writable, does nothing. No feedback to player provided. (They should audit to find out)
func set_iota(iota):
	if sb_write:
		sb[sb_sel] = iota

# Increment the currently selected iota in the spellbook.
func inc_sb():
	sb_sel = (sb_sel + 1) % sb.size()

# Decrement the currently selected iota in the spellbook.
func dec_sb():
	sb_sel = (sb_sel - 1 + sb.size()) % sb.size()

# Display string for entity.
func _to_string():
	return "Entity: " + name

# Position getters
func get_pos():
	return node.position

# (For display uses)
func get_fake_pos():
	return Entity.real_to_fake(node.position)

# Position setters
# func set_pos(pos): # Commented out while not in use
# 	node.position = pos

# Turns out setting fake pos is convenient when impulsing.
func set_fake_pos(pos):
	node.position = Entity.fake_to_real(pos)

# Velocity get (Returns 0,0 if no velocity var)
func get_fake_vel():
	if "velocity" in node:
		return Entity.real_to_fake(node.velocity)
	else:
		return Vector2.ZERO

# Set sentinel, and show/hide based on null status. (Only player sentinels are visible)
func set_sentinel(pos):
	sentinel_pos = pos
	if name == "Player": # Do not display sentinels for non-player entities.
		if sentinel_pos == null:
			node.sentinel.visible = false
		else:
			node.sentinel.visible = true
			node.sentinel.position = sentinel_pos * Entity.FAKE_SCALE

# Death function. Deletes the entity node and cleans up.
# Should NOT be called through entity. Pass entity to level_base and delete via there.
func delete():
	node.queue_free()
	node = null
	sb = null # This and raven likely unneeded, but just in case.
	ravenmind = null


# Coordinate conversions
# Fake takes 0,0 as centre of top left tile, but actual positions take 0,0 as top left CORNER
# Additionally, one tile is 64 pixels. so x64 to convert fake to real, /64 to convert real to fake
# Fake coordinates are for input/output, real coordinates are for mathing on and storing.

static var FAKE_SCALE = 64 # This val directly used by some patterns needing to convert fake distances to real distances. (Floats)

static func fake_to_real(level_pos: Vector2):
	return level_pos * FAKE_SCALE

static func real_to_fake(screen_pos: Vector2):
	return screen_pos / FAKE_SCALE
