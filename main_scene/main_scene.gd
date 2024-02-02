@tool
extends Node2D

@onready var hexecutor = null

@export var grid: Node2D
@onready var hex_display = $HexDisplay
@export var level_container: SubViewportContainer
@onready var level_viewport = level_container.get_child(0)

var world_view_scene = preload("res://worlds/world_view.tscn") 

var loaded_level = null # Currently loaded level (Child of level_control)
var level_list = [] # List of arrays that represent levels other than the loaded level. Appended to on new level load.
# Pairs are in [[level_node, hexecutor, level_haver]] format.

# For now, just load the hub scene
func _ready():
	load_level_from_scene(preload("res://levels/island_1/external_hub_1/level.tscn"))

# Unloads and saves the current level to level_list, then loads a new level given by the level_haver
func save_then_load_level(level_haver: LevelHaver):
	# Save current level to level_list, along with hexecutor and the level_haver
	level_list.push_back([loaded_level, hexecutor, level_haver])
	# Remove the level as a child
	level_viewport.remove_child(loaded_level)
	loaded_level = null
	# Clear grid
	grid.reset(true) # Hard reset, clears border score
	# Load scene
	var scene = level_haver.get_level()
	load_level_from_scene(scene)

func load_level_from_scene(scene: PackedScene):
	# Load level
	loaded_level = scene.instantiate()
	level_viewport.add_child(loaded_level)
	if Engine.is_editor_hint():
		return # Don't update rest of scene if in editor
	
	# Prepare level with reference to self and scene
	loaded_level.main_scene = self
	loaded_level.scene = scene

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(loaded_level, loaded_level.player.entity, self)

	# Update hex_display, level desc
	update_hex_display()
	hex_display.update_level_desc_label(loaded_level.validator.desc)

func reload_current_level(reset_border_score: bool, new_seed: int = -1):
	# Prep new level (Seed is important for reload, as often same or specific seed is wanted)
	var new_level = loaded_level.scene.instantiate()
	new_level.main_scene = self
	new_level.scene = loaded_level.scene
	new_level.level_seed = loaded_level.level_seed if new_seed == -1 else new_seed # Keep seed if not specified

	# Unload and delete current level
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	grid.reset(reset_border_score) # Soft reset, saves border score

	# Adopt new level
	loaded_level = new_level
	level_viewport.add_child(loaded_level)
	
	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(loaded_level, loaded_level.player.entity, self)

	# Update hex_display
	update_hex_display()
	#hex_display.update_level_desc_label(loaded_level.validator.desc) # Level desc shouldn't change


# Unloads the current level and loads the last level in level_list
# Returns false if there are no levels to load
func exit_level():
	if level_list.size() == 0:
		# No levels to load, return false
		return false

	var prev_level_stuff = level_list.pop_back()
	# Unload and delete current level
	var level_validated = loaded_level.validated # For use in updating level_haver \/
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	grid.reset(true) # Hard reset, clears border score

	# Load previous level
	loaded_level = prev_level_stuff[0]
	level_viewport.add_child(loaded_level)
	hexecutor = prev_level_stuff[1]
	hexecutor.scram_mode = false # Disable scram mode so patterns can run again.

	# Update hex_display, level desc
	update_hex_display()
	hex_display.update_level_desc_label(loaded_level.validator.desc)

	# Update level_haver iota readability
	prev_level_stuff[2].entity.readable = level_validated

	# Success
	return true

# Transition from current level to the world view.
# 0 for main world, 1 for island 1 internal world, etc.
func transition_to_world(world_id: int):
	hexecutor.level_base = null # Remove reference to level_base, disables hexecutor.
	var world_view = world_view_scene.instantiate()
	world_view.main_scene = self # So it can request to transition FROM world
	var player = loaded_level.player
	loaded_level.remove_child(player) # So it can be added to world_view
	world_view.prepare(player, world_id, loaded_level.scene_file_path) # Load player into new world
	hexecutor.caster = player.entity # Set caster to new player's entity
	loaded_level.kill_all_entities() # Prevent living references. (Player will still be alive and have these references)
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	level_viewport.add_child(world_view) # New scene being shown.
	loaded_level = world_view # Done!
	update_hex_display() # Refresh display (Now-Dead entities, level desc)
	hex_display.update_level_desc_label(world_view.world_script.desc)

# Transition from world view to selected level.
func transition_from_world(selected_level: PackedScene):
	var new_level = selected_level.instantiate()
	new_level.main_scene = self # So it can request to transition FROM world
	new_level.scene = selected_level # For reloading
	var player = loaded_level.player
	loaded_level.remove_child(player) # So it can be added to world_view
	new_level.use_player(player, -player.velocity.normalized()) # Load player into level
	hexecutor.caster = player.entity # Set caster to new player's entity
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	level_viewport.add_child(new_level) # New scene being shown.
	hexecutor.level_base = new_level
	loaded_level = new_level # Done!
	update_hex_display() # Refresh display (New level desc etc)
	hex_display.update_level_desc_label(new_level.validator.desc)


# Validates the current level
func validate_level():
	if loaded_level.has_method("validate"):
		return loaded_level.validate()
	else:
		return false

# Called with new patterns from grid. Executes them using hexecutor
func new_pattern_drawn(pattern):
	hexecutor.new_pattern(pattern)

# Update hex_display (Normally after a pattern is executed)
# Takes hexecutor to get stack/caster info etc
func update_hex_display():
	hex_display.update_all_hexy() # Update stack display

# Update border size display, also located in hex_display.
func update_border_display():
	hex_display.update_border_label(grid.hex_border.border_score, grid.hex_border.perimeter, grid.hex_border.cast_score)

# Clear grid, all patterns and reset stack
func clear():
	grid.reset(false) # Soft reset, keeps previous border score
	hexecutor.reset()
	hex_display.update_clear_hexy() # Update/Clear stack display

# End replay mode, normally after player casts a pattern manually
func end_replay_mode():
	if hex_display.replay_mode:
		hex_display.end_replay()

# Player casting functions
func _input(event):
	if not Globals.player_control:
		return # Player control required
	if event is InputEventMouseButton:
		# If right click, duplicates then executes the currently selected spellbook pattern.
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Increment border score by 2 (Arbitrary, but seems fine)
			grid.hex_border.inc_cast_score(2)
			# Duplicate the spellbook iota 
			hexecutor.execute_pattern(Pattern.new("1Llllll")) # Scribe's Reflection
			# Execute the iota
			hexecutor.execute_pattern(Pattern.new("1RrLll")) # Hermes' Gambit
			# Play a sound
			SoundManager.play_hermes()
			return # Done
		# If scroll wheel, cycle through spellbook patterns (Down for increment, up for decrement)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Increment border score by 1 (Again, arbitrary)
			grid.hex_border.inc_cast_score(1)
			# Increment spellbook
			hexecutor.caster.node.inc_sb()
			# Update displays
			hex_display.update_sb_label(hexecutor.caster.node)
			# Play a sound
			SoundManager.play_segment()
			return # Done
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Increment border score by 1
			grid.hex_border.inc_cast_score(1)
			# Decrement spellbook
			hexecutor.caster.node.dec_sb()
			# Update displays
			hex_display.update_sb_label(hexecutor.caster.node)
			# Play a sound
			SoundManager.play_segment()
			return # Done
