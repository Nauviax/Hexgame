extends Node2D
class_name Level_Base
# Base level for all other levels

# Reference to main_scene, purely to request a level transition (To world view)
# Should not be used to get hexecutor or anything else. Open to better ways to do this.
var main_scene: Main_Scene

# Reference to scene used to make this level
# Used to reload level quickly
var scene: PackedScene

# Level_logic and initiator for this level
@export var level_logic: Script
@export var initiator: Script

# Level seed (Random on _ready() if -1)
var level_seed: int = -1
var rnd: RandomNumberGenerator # Set in _ready()

# Level background theme
@export var bg_theme: String = "Inside"

# If true, show validate and replay buttons, and keep track of patterns executed for replay.
# Additionally, disable player flight. (Levitation works as normal)
@export var is_level_puzzle: bool = true # False for level hubs mainly

# True if level has been validated (And level_logic.validate() returned true)
var is_level_valid: bool = false

# List of entities in the level (Entity object, not Node2D)
var entities: Array

# List of objects in the level (Actual Node2D, can be queue_free-ed) (Like entities but less functionality)
var objects: Array

# Player object for the level 
@onready var player: Player = $Player

# Most recently revealed iota (For level verification)
var revealed_iota: Variant = null

# Tilemap for the level
@onready var tilemap: TileMap = $TileMap

# Tilemap calculated centre and size (Real coords not fake)
@onready var level_centre: Vector2 = $BottomRightPoint.position / 2
@onready var level_size: float = max(level_centre.x, level_centre.y) * 2
var transition_multiplier: float = 5 # Distance player is placed on transition, and how far to go to leave. (While flying)

# Raycast objects for the level (Enabled = false)
@onready var raycast_b: RayCast2D = $HexBlockRaycast
@onready var raycast_e: RayCast2D = $HexEntityRaycast
@onready var raycast_i: RayCast2D = $HexImpulseRaycast

# Generate rest of base level info
func _ready() -> void:
	# Get entities and objecets
	reload_entities_list()
	# Set random seed if still -1
	if level_seed == -1:
		level_seed = randi()
	rnd = RandomNumberGenerator.new()
	rnd.seed = level_seed
	# Apply initiator to level
	initiator.initiate(self)
	# Set background theme
	player.set_background_theme(bg_theme)
	# Set player's can_fly based on is_level_puzzle
	player.can_fly = not is_level_puzzle

# Reload entities and objects list
#  Get all children, add to entities array if they are an entity
#  (Includes player)
func reload_entities_list() -> void:
	entities = []
	objects = []
	for child in get_children():
		if "entity" in child: # All entity nodes have an entity object
			entities.append(child.entity)
		if "obj_name" in child: # All objects have an obj_name variable
			objects.append(child)
	

# Takes a player entity, and replaces the current player with the new one.
# Also takes a direction to move the player to, as a normalised vector2. (As this function is called when a player is entering the level)
func use_player(player_new: Player, dir: Vector2) -> void:
	# Ensure relevant @onready things are got (Normally skipped when this is called quickly)
	player = $Player
	level_centre = $BottomRightPoint.position / 2
	level_size = max(level_centre.x, level_centre.y) * 2
	# Remove and delte old player
	remove_child(player)
	player.queue_free()
	# Add new player to level and update it's data
	player = player_new
	add_child(player_new)
	reload_entities_list() # Refresh entities list
	player.trailer_pgen.restart() # Clear stragglers
	player.stuck_flying = false # Player can land again
	player.position = level_centre + (dir * level_size * transition_multiplier) # Move player to edge of level
	# Reload sentinel
	player.sentinel = $PlayerSentinel
	player.sentinel_pos = null

# Update function for the level.
# Will respawn player if they end up illegally outside the level.
# Will transition player to world map if they are more than 2.5 level_sizes away from the level centre.
var process_count: int = 0
func _physics_process(_delta: float) -> void:
	if not Globals.player_control:
		return # Player control required
	process_count += 1
	if process_count >= 30: # Twice a second, roughly
		process_count = 0
		if (not player.flying) and get_tile_id(player.entity.get_fake_pos(), 0) == 0: # If player is not on a tile
			player.position = player.respawn_point # Move player to respawn point
		if player.flying and player.position.distance_to(level_centre) > level_size * (transition_multiplier + 0.1): # If player is flying and is far away from the level centre
			main_scene.transition_to_world() # Transition player to world map

# Test if the level is complete (And save result)
func validate() -> void:
	if level_logic == null:
		is_level_valid = false
	else:
		is_level_valid = level_logic.validate(self)

# Remove an entity from the level, effectively killing it. Returns false on failure.
func remove_entity(entity: Entity) -> bool:
	if not entity.killable: # Player for example, can't be killed
		return false
	entities.erase(entity)
	remove_child(entity.node)
	entity.delete()
	return true

# Raycasts for hexes (Uses literal/actual positions)
static var raycast_dist: int = 1024 # (16 * 64, or 16 tiles)

# Can optionally use dir magnitude as distance, but uses 16 tiles by default.
# All raycasts can return null, hence the Variant return value.
func block_raycast(pos: Vector2, dir: Vector2, normalized: bool = true) -> Variant: # Ignores glass
	if normalized:
		raycast_b.target_position = dir * raycast_dist
	else:
		raycast_b.target_position = dir # Use dir magnitude as distance
	raycast_b.position = pos
	raycast_b.force_raycast_update() # Works while disabled
	if not raycast_b.is_colliding():
		return null
	var hit_pos: Vector2 = tilemap.to_local(raycast_b.get_collision_point()) # tilemap.local because later tilemap.local_to_map
	var adj_pos: Vector2 = hit_pos - (raycast_b.get_collision_normal() * Entity.FAKE_SCALE / 2) # Nudge half a tile's width (Correct tile selection)
	return Vector2(tilemap.local_to_map(adj_pos))

func block_side_raycast(pos: Vector2, dir: Vector2) -> Variant: # Ignores glass, returns both normal and collision point (point for particles only)
	raycast_b.target_position = dir * raycast_dist
	raycast_b.position = pos
	raycast_b.force_raycast_update() # Works while disabled
	if not raycast_b.is_colliding():
		return null
	return [raycast_b.get_collision_normal(), raycast_b.get_collision_point()]

func entity_raycast(pos: Vector2, dir: Vector2) -> Variant:
	raycast_e.target_position = dir * raycast_dist
	raycast_e.position = pos
	raycast_e.force_raycast_update() # Works while disabled
	var hit: Object = raycast_e.get_collider()
	if hit == null or not "entity" in hit: # If we hit something that isn't an entity (Like a wall)
		return null # Miss
	return hit.entity

# Raycast like block_raycast, but hits glass and takes an offset (Un-normalized literal direction vector basically)
#  - Don't forget to multiply tile offsets by Entity.FAKE_SCALE
# Additionally, this raycast returns the literal/actual position of the hit, not the tile position
# On a miss, returns pos + offset (Max distance)
func impulse_raycast(pos: Vector2, offset: Vector2, is_levitating: bool) -> Vector2:
	var fs: int = Entity.FAKE_SCALE # Used here often enough to justify a shorter name
	if is_levitating: # Disable collision with spikes if levitating (Layer 4)
		raycast_i.set_collision_mask_value(4, false)
	raycast_i.target_position = offset
	raycast_i.position = pos
	raycast_i.force_raycast_update() # Works while disabled
	if not raycast_i.is_colliding():
		return (pos + offset) / fs
	var hit_pos: Vector2 = to_local(raycast_i.get_collision_point()) # self.local because we aren't directly using tilemap
	var adj_pos: Vector2 = hit_pos + offset/1000 # Get point just after hit to guarantee checking if hit tile is spikes
	if is_levitating: # Possibly redundant if statement, but ehhh
		raycast_i.set_collision_mask_value(4, true)
	return adj_pos / fs

# Returns true if an entity is on the given tile
# Takes a tile position (Uses fake/tilemap position system)
func entity_at(pos: Vector2) -> bool:
	var pos_true: Vector2 = pos * Entity.FAKE_SCALE
	for entity: Entity in entities:
		if entity.get_pos() == pos_true:
			return true
	return false

# Methods for getting tileID at a position (Uses fake/tilemap position system) 
# Layer 0 is tiles, layer 1 is toppers
# Tile ID for tilemap:
# Layer 0
#  00 = Undefined / Out of map
#  01 = Wall (Includes that wall tile with no collision)
#  02 = Glass
#  03 = Basic floor (White, Grass etc)
#  04 = Green floor
#  05 = Red floor
# Layer 1
#  21 = Spikes
#  22 = Gate
func get_tile_id(pos: Vector2, layer: int) -> int:
	var data: TileData = tilemap.get_cell_tile_data(layer, pos.round()) # Round pos, as tilemap will floor it otherwise.
	if data == null:
		return 0
	return data.get_custom_data("TileID")

# Return a list of entities on a given tile
# Takes a tile ID, assumes layer 0. Optionally get entities not on the tile.
func entities_on_tile(tile_id: int, on_tile: bool = true) -> Array:
	var entities_on_tile: Array = []
	for entity: Entity in entities:
		if (get_tile_id(entity.get_fake_pos(), 0) == tile_id) == on_tile:
			entities_on_tile.append(entity)
	return entities_on_tile

# Force kill all entities in the level, excluding player.
# Used to prevent old entities being used when a level is left.
# NOT required on level exit. Exit clears the player spellbook so no references remain.
func kill_all_entities() -> void:
	for entity: Entity in entities:
		if entity != player.entity:
			entity.delete()
