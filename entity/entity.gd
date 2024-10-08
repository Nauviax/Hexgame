class_name Entity
extends Resource # Should mean this object gets deleted automatically when not in use.

# Info regarding this entity, set on _init()
var name: String # Entity name, display and randomizer purposes
var node: Node2D # Node/Object that this entity is attached to.
var look_dir: Vector2 = Vector2(0.0, -1.0) # Init just look up. (Normalized vector)
var alive: bool = true # True if this entity is alive. (Equal to Node is not null)
# Dead entities return null for iota reads, and Vector2.ZERO for position reads.
# Any sets to dead entities are ignored, and no feedback is provided to the player.

# Generic readability and writeability for this entity when iota/sb is accessed externally. (Default neither)
var readable: bool = false
var writeable: bool = false

# Per-Entity variables that affect what spells affect them.
var killable: bool = true # Explosion, Impulse into spikes
var moveable: bool = true # Teleport, Impulse, Levitating etc (set_pos and similar still function, this must be checked per spell!)

# True if this entity is levitating. (Via Levitate spell)
var is_levitating: bool = false:
	set(val):
		is_levitating = val
		if val and (not levitation_particle_gen): # If levitating and no particle generator, create one.
			levitation_particle_gen = levitation_particle_gen_scene.instantiate()
			node.add_child(levitation_particle_gen)
		elif (not val) and levitation_particle_gen: # If not levitating and particle generator exists, delete it.
			levitation_particle_gen.queue_free()
			levitation_particle_gen = null

# Particle generator scene for levitation effect. Should be added as a child of "node" when levitating.
var levitation_particle_gen_scene: PackedScene = preload("res://resources/particles/levitation_particle_gen.tscn")
var levitation_particle_gen: Node2D = null

# Constructor
func _init(name: String, node: Node2D) -> void:
	self.name = name
	self.node = node

# Returns the readable iota for this entity, if it exists.
# If the entity isn't readable, always returns null. No feedback to player provided. (They should audit to find out)
func get_iota() -> Variant:
	if readable and alive: # If readable and alive
		return node.get_iota() # If readable and this node doesn't have get_iota(), *something* bad will happen. Don't do that.
	else:
		return null

# Sets the currently selected iota in the spellbook.
# If the entity isn't writable, does nothing. No feedback to player provided. (They should audit to find out)
func set_iota(iota: Variant) -> void:
	if writeable and alive:
		node.set_iota(iota) # Same deal as get_iota()

# Display string for entity.
func _to_string() -> String:
	return "Entity: " + name + ("" if alive else " (Dead)")

# Position getters
func get_pos() -> Vector2:
	if not alive: # Dead entity.
		return Vector2.ZERO
	return node.position

# (For display uses)
func get_fake_pos() -> Vector2:
	if not alive: # Dead entity.
		return Vector2.ZERO
	return Entity.real_to_fake(node.position)

# Turns out setting fake pos is convenient when impulsing.
func set_fake_pos(pos: Vector2) -> void:
	if alive:
		node.position = Entity.fake_to_real(pos)

# Velocity get (Returns 0,0 if no velocity var)
func get_fake_vel() -> Vector2:
	if "velocity" in node and alive:
		return Entity.real_to_fake(node.velocity)
	else:
		return Vector2.ZERO # No velocity var, or dead entity.

# Death function. Deletes the entity node and cleans up.
# Should NOT be called through entity. Pass entity to level_base and delete via there.
func delete() -> void:
	alive = false # Set alive to false, so that other functions know this entity is dead.
	node.queue_free()
	node = null

# Coordinate conversions
# Fake takes 0,0 as centre of top left tile, but actual positions take 0,0 as top left CORNER
# Additionally, one tile is 64 pixels. so x64 to convert fake to real, /64 to convert real to fake
# Fake coordinates are for input/output, real coordinates are for mathing on and storing.

static var FAKE_SCALE: int = 64 # This val directly used by some patterns needing to convert fake distances to real distances. (Floats)

static func fake_to_real(level_pos: Vector2) -> Vector2:
	return level_pos * FAKE_SCALE

static func real_to_fake(screen_pos: Vector2) -> Vector2:
	return screen_pos / FAKE_SCALE
