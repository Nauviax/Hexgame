extends Node2D
# Travel hub for moving between levels. Casting is disabled here. 
# Additionally, hexecutor should contain no level_base reference while this scene is loaded.

# Reference to main_scene, purely to request a level transition (To a given level)
# Should not be used to get hexecutor or anything else. Open to better ways to do this.
var main_scene: Main_Scene

# Player object for the world 
var player: Player

# List of level_in_world nodes added as children
var levels: Array

# Levels that this world contains
# Format: [position, level path, display name]
static var levels_data: Array = [
	[Vector2(-1000, -1000), "res://levels/island_1/external_hub_1/level.tscn", "Island 1"],
	[Vector2(1000, -1000), "res://levels/island_2/external_hub_2/level.tscn", "Island 2"],
]

# Reference to level_in_world scene, to load level hitboxes into world.
@export var liw_scene: PackedScene

# Handle on_tick logic for world_view
func _physics_process(_delta: float) -> void:
	if not Globals.player_control:
		return # Player control required

	# If the player moves too far away, invert their position and bring slightly closer.
	if player.position.distance_to(Vector2.ZERO) > 5000:
		player.position = player.position * -0.75
	
	# Move each level_in_world node's pointer to the player's position, offset towards the level it's from
	var player_pos: Vector2 = player.position
	for level: Area2D in levels:
		level.pointer.position = player_pos - level.position + player_pos.direction_to(level.position) * 150 # 150 pixels from player
		# Slowly fade the pointer in using modulate
		level.pointer.modulate.a = clamp(level.pointer.modulate.a + 0.025, 0, 1)

# Function for loading the player into the world
# Takes a player to use, and the filepath of the world the player is coming from
func prepare(player_new: Player, from_filepath: String) -> void:
	# Add player to the world
	player = player_new
	add_child(player_new)
	player.stuck_flying = true
	player.trailer_pgen.restart() # Clear stragglers
	# Clear sentinel
	player.sentinel = null
	player.sentinel_pos = null

	# Load world around player
	for level: Array in levels_data:
		# Create new level_in_world scene
		var level_in_world: Area2D = liw_scene.instantiate()
		add_child(level_in_world)
		levels.append(level_in_world) # Save node reference
		level_in_world.position = level[0] # Position in world
		level_in_world.level_path = level[1] # Path to level file
		level_in_world.level_name = level[2] # Display name of level
		# Check if player came from this level
		if level[1] == from_filepath:
			# Set player position to level position 
			player.position = level[0]

	# Connect player's spike checker Area2D to the relevant function here # !!! Does this ever get disconnected?
	player.get_node("SpikeChecker").area_entered.connect(_on_player_area_entered)

# Function for loading a level from the world
# - As player starts inside an area, the first call is ignored.
# - This borrows the player's spike detector, rather than making a new Area2D
var first_call: bool = true
func _on_player_area_entered(area: Area2D) -> void:
	if first_call: # Ignore starting area
		first_call = false
		return
	level_path_to_load = area.level_path # Save path to level
	# call_deferred() to avoid issues with Area2D, as it gets deleted when this is called
	call_deferred("transition_to_main") # Switch to level
	# Move all level_in_world pointer nodes to be children of the player, and set their positions to be relative to the player
	for level: Area2D in levels:
		var pointer: Sprite2D = level.pointer
		level.remove_child(pointer)
		player.add_child(pointer)
		pointer.fade_out = true # Begin fading out, and remove when done

# Deffered function for transitioning to the saved level
var level_path_to_load: String
func transition_to_main() -> void:
	main_scene.transition_from_world(load(level_path_to_load))
