extends Node2D
# Base level is currently for debugging. Not intended to be in final game.
# Eventually move most creation content out of level_base.gd

# List of entities in the level
var entities: Array

# Player object for the level 
@onready var player = $Player

# Tilemap for the level
@onready var tilemap = $TileMap

# Raycast objects for the level (Enabled = false)
@onready var raycast_b = $Hex_Block_Raycast
@onready var raycast_e = $Hex_Entity_Raycast

# Generate rest of base level info
func _ready():
	# Get all children, add to entities array if they are an entity (!!!)
	for child in get_children():
		if "entity" in child:
			entities.append(child.entity)


# Raycasts for hexes
static var raycast_dist = 1024 # (16 * 64, or 16 tiles)
func block_raycast(pos, dir):
	raycast_b.target_position = dir * raycast_dist
	raycast_b.position = pos
	raycast_b.force_raycast_update() # Works while disabled
	if not raycast_b.is_colliding():
		return null
	var hit_pos = tilemap.to_local(raycast_b.get_collision_point())
	var adj_pos = hit_pos - (raycast_b.get_collision_normal() * Entity.FAKE_SCALE / 2) # Nudge half a tile's width (Correct tile selection)
	return tilemap.local_to_map(adj_pos)

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
	# if not raycast_e.is_colliding():
	# 	return null # Possibly redundant, but at least no surprises.
	var hit = raycast_e.get_collider()
	if hit == null:
		return null # Miss
	var hit_parent = hit.get_parent()
	if not "entity" in hit_parent: # If we hit something that isn't an entity (Like a wall)
		return null
	return hit_parent.entity
