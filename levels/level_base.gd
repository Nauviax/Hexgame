extends Node2D
# Base level is currently for debugging. Not intended to be in final game.
# Eventually move most creation content out of level_base.gd

# Validator and Randomizer for this level
@export var validator: Script
@export var randomizer: Script

# List of entities in the level
var entities: Array

# Player object for the level 
@onready var player = $Player

# Tilemap for the level
@onready var tilemap = $TileMap

# Raycast objects for the level (Enabled = false)
@onready var raycast_b = $Hex_Block_Raycast
@onready var raycast_e = $Hex_Entity_Raycast
@onready var raycast_i = $Hex_Impulse_Raycast

# Generate rest of base level info
func _ready():
	# Get all children, add to entities array if they are an entity (!!!)
	for child in get_children():
		if "entity" in child:
			entities.append(child.entity)
	# Apply randomizer to level
	randomizer.randomize(self)

# Test if the level is complete
func validate():
	return validator.validate(self)

# Remove an entity from the level, effectively killing it. Returns false on failure. (When killing player)
func remove_entity(entity):
	if entity.node == player:
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

# Methods for getting tiles at a position (Uses fake/tilemap position system) 
# Layer 0 is tiles, layer 1 is toppers
# Current return values are funky, but are as follows:
# 0 = Wall(inc glass) or Spike (Depending on layer)
# 1 = White floor or Gate/TP (Depending on layer)
# 2 = Green floor
# 3 = Red floor
# -1 = default (Invalid normally)
func get_tile(pos, layer):
	var atlas = tilemap.get_cell_atlas_coords(layer, pos.round()) # Round pos, as tilemap will floor it otherwise.
	if layer == 0:
		match atlas:
			Vector2i(1,0), Vector2i(0,1): # Wall, Glass
				return 0
			Vector2i(1,1): # White floor
				return 1
			Vector2i(0,2): # Green floor
				return 2
			Vector2i(1,2): # Red floor
				return 3
			_:
				return -1
	else:
		match atlas:
			Vector2i(0,0): # Spikes
				return 0
			Vector2i(0,1): # Gate/TP
				return 1
			_:
				return -1
