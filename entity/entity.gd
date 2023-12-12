class_name Entity

# Info regarding this entity, set on _init()
var disp_name # Display name for entity
var position # (0.0, 0.0)
var looking_dir # (1.0, 0.0), normalized vector
var velocity # (0.0, 0.0), Speed is magnitude, direction would be normalized vector
var team # 0 = Neutral, 1 = Friendly/Player, -1 = Hostile

var sb = [null] # List of iotas that this entity is storing.
var sb_names = ["0"] # List of names of iotas in spellbook, for display purposes.
var sb_sel = 0 # Index of currently selected iota in spellbook.
var sb_read = true # True if other entities can read from this entity's spellbook. (Selected iota only)
var sb_write = true # True if other entities can write to this entity's spellbook. (Selected iota only)
# Spellbook size should be fixed, so no push/pop, just set/get. (Unless specifically trying to expand/shrink spellbook size)
# For external reading/writing, use provided get/set functions.

var ravenmind = null # Ravenmind iota. Not readable/writable by other entities, and lost on grid clear (Assuming this entity can cast)

# Constructor
func _init(name, pos = Vector2(0, 0), team = 0, look = Vector2(1, 0), vel = Vector2(0, 0)):
	self.disp_name = name
	self.position = pos
	self.team = team
	self.looking_dir = look
	self.velocity = vel

# Sets values for spellbook. Mainly for setting sb_read/write, but can also be used to set spellbook size / default values.
func set_spellbook(sb_read = true, sb_write = true, sb:Array = [null], gen_names = true):
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
	return "Entity: " + disp_name
