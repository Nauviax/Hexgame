extends Node2D
# Base level for all other levels

# Reference to main_scene, purely to request a level transition (To world view)
# Should not be used to get hexecutor or anything else. Open to better ways to do this.
var main_scene

# String ID for the level
# Generally in format "1-1", "1-2", but can contain letters ("1-h" for starting level hub)
@export var level_id: String

# Validator and initiator for this level
@export var validator: Script
@export var initiator: Script

# True if level has been validated (And validator returned true)
var validated = false

# List of entities in the level
var entities: Array

# Player object for the level 
@onready var player: Player = $Player

# Most recently revealed iota (For level verification)
var revealed_iota = null

# Tilemap for the level
@onready var tilemap = $TileMap

# Tilemap calculated centre and size (Real coords not fake)
@onready var level_centre = $Bottom_Right_Point.position / 2
@onready var level_size = max(level_centre.x, level_centre.y) * 2

# Raycast objects for the level (Enabled = false)
@onready var raycast_b = $Hex_Block_Raycast
@onready var raycast_e = $Hex_Entity_Raycast
@onready var raycast_i = $Hex_Impulse_Raycast

# Generate rest of base level info
func _ready():
	# Get entities
	reload_entities_list()
	# Apply initiator to level
	initiator.initiate(self)

# Reload entities list
#  Get all children, add to entities array if they are an entity
#  (Includes player)
func reload_entities_list():
	entities = []
	for child in get_children():
		if "entity" in child:
			entities.append(child.entity)

# Takes a player entity, and replaces the current player with the new one.
# Also takes a direction to move the player to, as a normalised vector2. (As this function is called when a player is entering the level)
func use_player(player_new: Player, dir: Vector2):
	# Ensure relevant @onready things are got (Normally skipped when this is called quickly)
	player = $Player
	level_centre = $Bottom_Right_Point.position / 2
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
	player.position = level_centre + (dir * level_size * 3) # Move player to edge of level
	# Reload sentinel
	player.sentinel = $Player_Sentinel
	player.sentinel_pos = null

# Update function for the level.
# Will respawn player if they end up illegally outside the level.
# Will transition player to world map if they are more than 2.5 level_sizes away from the level centre.
var process_count = 0
func _physics_process(_delta):
	process_count += 1
	if process_count >= 60: # Every second, roughly
		process_count = 0
		if (not player.flying) and get_tile_id(player.entity.get_fake_pos(), 0) == 0: # If player is not on a tile
			player.position = player.respawn_point # Move player to respawn point
		if player.flying and player.position.distance_to(level_centre) > level_size * 3.5: # If player is flying and is more than 3.5 level_sizes away from the level centre
			main_scene.transition_to_world()

# Test if the level is complete (And save result)
func validate():
	validated = validator.validate(self)
	return validated

# Remove an entity from the level, effectively killing it. Returns false on failure.
func remove_entity(entity):
	if not entity.killable: # Player for example, can't be killed
		return false
	entities.erase(entity)
	remove_child(entity.node)
	entity.delete()
	return true

# Raycasts for hexes (Uses literal/actual positions)
static var raycast_dist = 1024 # (16 * 64, or 16 tiles)

# Can optionally use dir magnitude as distance, but uses 16 tiles by default
func block_raycast(pos, dir, normalized = true):
	if normalized:
		raycast_b.target_position = dir * raycast_dist
	else:
		raycast_b.target_position = dir # Use dir magnitude as distance
	raycast_b.position = pos
	raycast_b.force_raycast_update() # Works while disabled
	if not raycast_b.is_colliding():
		return null
	var hit_pos = tilemap.to_local(raycast_b.get_collision_point()) # tilemap.local because later tilemap.local_to_map
	var adj_pos = hit_pos - (raycast_b.get_collision_normal() * Entity.FAKE_SCALE / 2) # Nudge half a tile's width (Correct tile selection)
	return Vector2(tilemap.local_to_map(adj_pos))

func block_side_raycast(pos, dir):
	raycast_b.target_position = dir * raycast_dist
	raycast_b.position = pos
	raycast_b.force_raycast_update() # Works while disabled
	if not raycast_b.is_colliding():
		return null
	return raycast_b.get_collision_normal()

func entity_raycast(pos, dir):
	raycast_e.target_position = dir * raycast_dist
	raycast_e.position = pos
	raycast_e.force_raycast_update() # Works while disabled
	var hit = raycast_e.get_collider()
	if hit == null or not "entity" in hit: # If we hit something that isn't an entity (Like a wall)
		return null # Miss
	return hit.entity

# Raycast like block_raycast, but hits glass and takes an offset (Un-normalized literal direction vector basically)
#  - Don't forget to multiply tile offsets by Entity.FAKE_SCALE
# Additionally, this raycast returns the literal/actual position of the hit, not the tile position
# On a miss, returns pos + offset (Max distance)
func impulse_raycast(pos, offset, is_floating):
	var fs = Entity.FAKE_SCALE # Used here often enough to justify a shorter name
	if is_floating: # Disable collision with spikes if floating (Layer 4)
		raycast_i.set_collision_mask_value(4, false)
	raycast_i.target_position = offset
	raycast_i.position = pos
	raycast_i.force_raycast_update() # Works while disabled
	if not raycast_i.is_colliding():
		return (pos + offset) / fs
	var hit_pos = to_local(raycast_i.get_collision_point()) # self.local because we aren't directly using tilemap
	var adj_pos = hit_pos + offset/1000 # Get point just after hit to guarantee checking if hit tile is spikes
	if is_floating: # Possibly redundant if statement, but ehhh
		raycast_i.set_collision_mask_value(4, true)
	return adj_pos / fs

# Returns true if an entity is on the given tile
# Takes a tile position (Uses fake/tilemap position system)
func entity_at(pos):
	var pos_true = pos * Entity.FAKE_SCALE
	for entity in entities:
		if entity.get_pos() == pos_true:
			return true
	return false

# Methods for getting tileID at a position (Uses fake/tilemap position system) 
# Layer 0 is tiles, layer 1 is toppers
# Tile ID for tilemap:
# Layer 0
#  00 = Undefined / Out of map
#  01 = Wall
#  02 = Glass
#  03 = Basic floor (White, Grass etc)
#  04 = Green floor
#  05 = Red floor
# Layer 1
#  21 = Spikes
#  22 = Gate
func get_tile_id(pos, layer):
	var data = tilemap.get_cell_tile_data(layer, pos.round()) # Round pos, as tilemap will floor it otherwise.
	if data == null:
		return 0
	return data.get_custom_data("TileID")

# Force kill all entities in the level, excluding player.
# Used to prevent old entities being used when a level is left.
# NOT required on level exit. Exit clears the player spellbook so no references remain.
func kill_all_entities():
	for entity in entities:
		if entity != player.entity:
			entity.delete()
