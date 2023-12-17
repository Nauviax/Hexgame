extends Node2D
# Base level is currently for debugging. Not intended to be in final game.
# Eventually move most creation content out of level_base.gd

# List of entities in the level
var entities: Array

# Player object for the level
@onready var player = $Player

# Generate rest of base level info
func _ready():
	# Get all children, add to entities array if they are an entity (!!!)
	for child in get_children():
		if "entity" in child:
			entities.append(child.entity)