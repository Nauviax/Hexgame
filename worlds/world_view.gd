extends Node2D
# Travel hub for moving between levels. Casting is disabled here. 
# Additionally, hexecutor should contain no level_base reference while this scene is loaded.

# Reference to main_scene, purely to request a level transition (To a given level)
# Should not be used to get hexecutor or anything else. Open to better ways to do this.
var main_scene

# Player object for the world 
var player: Player

# World script used to load the world, and holds world data
var world_script

# List of level_in_world nodes added as children # !!! Possibly unnecessary
var levels: Array

# Reference to level_in_world scene, to load level hitboxes into world.
@export var liw_scene: PackedScene

# Handle on_tick logic for world_view
func _physics_process(_delta):
	if not Globals.player_control:
		return # Player control required

	# If the player moves too far away, invert their position and bring slightly closer.
	if player.position.distance_to(Vector2.ZERO) > 5000:
		player.position = player.position * -0.75
	
	# Move each level_in_world node's pointer to the player's position, offset towards the level it's from
	var player_pos = player.position
	for level in levels:
		level.pointer.position = player_pos - level.position + player_pos.direction_to(level.position) * 100

# Function for loading the player into the world
# Takes a player to use, the world id to load, and the filepath of the world the player is coming from
func prepare(player_new: Player, world_id: int, from_filepath: String):
	# Add player to the world
	player = player_new
	add_child(player_new)
	player.stuck_flying = true
	player.trailer_pgen.restart() # Clear stragglers
	# Clear sentinel
	player.sentinel = null
	player.sentinel_pos = null

	# Load world around player
	world_script = load("res://worlds/world_scripts/world_" + str(world_id) + ".gd")
	for level in world_script.levels:
		# Create new level_in_world scene
		var level_in_world = liw_scene.instantiate()
		add_child(level_in_world)
		levels.append(level_in_world) # Save node reference
		level_in_world.position = level[0] # Position in world
		level_in_world.level_path = level[1] # Path to level file
		# Check if player came from this level
		if level[1] == from_filepath:
			# Set player position to level position 
			player.position = level[0]

	# Set background theme
	player.set_background_theme(world_script.theme)

	# Connect player's spike checker Area2D to the relevant function here
	player.get_node("Spike_Checker").area_entered.connect(_on_player_area_entered)

# Function for loading a level from the world
# - As player starts inside an area, the first call is ignored.
# - This borrows the player's spike detector, rather than making a new Area2D
var first_call = true
func _on_player_area_entered(area: Area2D):
	if first_call: # Ignore starting area
		first_call = false
		return
	level_path_to_load = area.level_path # Save path to level
	# call_deferred() to avoid issues with Area2D, as it gets deleted when this is called
	call_deferred("transition_to_main") # Switch to level

# Deffered function for transitioning to the saved level
var level_path_to_load
func transition_to_main():
	main_scene.transition_from_world(load(level_path_to_load))