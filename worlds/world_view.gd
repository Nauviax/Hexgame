extends Node2D
# Travel hub for moving between levels. Casting is disabled here. 
# Additionally, hexecutor should contain no level_base reference while this scene is loaded.

# Reference to main_scene, purely to request a level transition (To a given level)
# Should not be used to get hexecutor or anything else. Open to better ways to do this.
var main_scene

# Player object for the world 
var player: Player

# TEMP !!! Load hub world
var hub_world = preload("res://levels/island_1/external_hub_1/level.tscn")

# Temp ? !!! "Level" desc
var desc = "Between levels"

# Once player is sufficiently far away, switch back to the hub
func _physics_process(_delta):
	if player.position.distance_to(Vector2.ZERO) > 1000:
		# Switch back to the hub
		main_scene.transition_from_world(hub_world)

# Function for loading the player into the world
func use_player(player_new: Player, _from_id: String):
	player = player_new
	add_child(player_new)
	player.stuck_flying = true
	player.position = Vector2.ZERO # !!! Placeholder
	player.trailer_pgen.restart() # Clear stragglers
	# Clear sentinel
	player.sentinel = null
	player.sentinel_pos = null


