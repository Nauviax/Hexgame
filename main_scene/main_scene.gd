@tool
extends Node2D
class_name Main_Scene

@onready var hexecutor: Hexecutor = null

@export var grid: Node2D
@onready var hex_display: Hex_Display = $HexDisplay
@export var level_container: SubViewportContainer
@onready var level_viewport: SubViewport = level_container.get_child(0)

var world_view_scene: PackedScene = preload("res://worlds/world_view.tscn") 

var loaded_level: Node2D = null # Currently loaded level (Child of level_control, CAN BE LEVEL OR WORLD, so don't use level_base)
var level_list: Array = [] # List of arrays that represent levels other than the loaded level. Appended to on new level load.
# Pairs are in [[level_node, hexecutor, level_haver]] format.

# For now, just load the hub scene
func _ready() -> void:
	load_level_from_scene(preload("res://levels/island_1/level_hub_1/level.tscn"))

# Unloads and saves the current level to level_list, then loads a new level given by the level_haver
func save_then_load_level(level_haver: Level_Haver) -> void:
	# Save current level to level_list, along with hexecutor and the level_haver
	level_list.push_back([loaded_level, hexecutor, level_haver])
	# Remove the level as a child
	level_viewport.remove_child(loaded_level)
	loaded_level = null
	# Clear grid
	grid.reset(true) # Hard reset, clears border score
	# Load scene
	var scene: PackedScene = level_haver.get_level()
	load_level_from_scene(scene)

func load_level_from_scene(scene: PackedScene) -> void:
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

	# Update hex_display, level tools
	update_hex_display_on_level_change(true, loaded_level.is_level_puzzle)

# Reset level, optionally keep seed.
func reload_current_level(same_seed: bool) -> void:
	# Prep new level (Seed is important for reload, as often same or specific seed is wanted)
	var new_level: Level_Base = loaded_level.scene.instantiate()
	new_level.main_scene = self
	new_level.scene = loaded_level.scene
	new_level.level_seed = loaded_level.level_seed if same_seed else -1 # Keep seed by default, -1 to force random

	# Unload and delete current level
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	grid.reset(true) # Hard reset, reset border score

	# Adopt new level
	loaded_level = new_level
	level_viewport.add_child(loaded_level)
	
	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(loaded_level, loaded_level.player.entity, self)

	# Update hex_display
	update_hex_display_on_level_change(true, loaded_level.is_level_puzzle)

# Unloads the current level and loads the last level in level_list
# Returns false if there are no levels to load
func exit_level() -> bool:
	if level_list.size() == 0:
		# No levels to load, return false
		return false

	var prev_level_stuff: Array = level_list.pop_back()
	# Unload and delete current level
	var level_validated: bool = loaded_level.is_level_valid # For use in updating level_haver \/
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	grid.reset(true) # Hard reset, clears border score

	# Load previous level
	loaded_level = prev_level_stuff[0]
	level_viewport.add_child(loaded_level)
	hexecutor = prev_level_stuff[1]
	hexecutor.scram_mode = false # Disable scram mode so patterns can run again.

	# Update hex_display, level tools
	update_hex_display_on_level_change(true, loaded_level.is_level_puzzle)

	# Update level_haver iota readability
	prev_level_stuff[2].entity.readable = level_validated

	# Success
	return true

# Transition from current level to the world view.
func transition_to_world() -> void:
	hexecutor.level_base = null # Remove reference to level_base, disables hexecutor.
	var world_view: Node2D = world_view_scene.instantiate()
	world_view.main_scene = self # So it can request to transition FROM world
	var player: Player = loaded_level.player
	loaded_level.remove_child(player) # So it can be added to world_view
	world_view.prepare(player, loaded_level.scene_file_path) # Load player into new world
	hexecutor.caster = player.entity # Set caster to new player's entity
	loaded_level.kill_all_entities() # Prevent living references. (Player will still be alive and have these references)
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	level_viewport.add_child(world_view) # New scene being shown.
	loaded_level = world_view # Done!
	update_hex_display_on_level_change(true, false) # Update hexy to clear entity references etc. World view isn't solveable, so no puzzle tools.

# Transition from world view to selected level.
func transition_from_world(selected_level: PackedScene) -> void:
	var new_level: Level_Base = selected_level.instantiate()
	new_level.main_scene = self # So it can request to transition FROM world
	new_level.scene = selected_level # For reloading
	var player: Player = loaded_level.player
	loaded_level.remove_child(player) # So it can be added to world_view
	new_level.use_player(player, -player.velocity.normalized()) # Load player into level
	hexecutor.caster = player.entity # Set caster to new player's entity
	level_viewport.remove_child(loaded_level)
	loaded_level.queue_free()
	level_viewport.add_child(new_level) # New scene being shown.
	hexecutor.level_base = new_level
	loaded_level = new_level # Done!
	update_hex_display_on_level_change(false, new_level.is_level_puzzle) # No need to update hexy, it won't have changed.

# Checks if the level is solved yet, also setting is_level_valid, and calls appropriate functions to update UI
# Returns true if level is solved, false if not.
func validate_level() -> bool:
	if loaded_level.has_method("validate"):
		loaded_level.validate() # Saves result to level also.
		hex_display.set_validate_result(loaded_level.is_level_valid) # Update UI to reflect validation result
		return loaded_level.is_level_valid
	else:
		hex_display.set_validate_result(false) # No validator, assume false (Likely world view)
		return false

# Validate the current hex on multiple versions of the level, to ensure the hex works on all versions.
# Returns [] on fail, and [hex size, border score] on success
func extra_validate_level() -> Array:
	var hex: Array = hexecutor.replay_list
	if hex.size() == 0:
		return [] # No patterns yet
	var border_score: int = grid.hex_border.get_score()
	# Consider blocking user input during validation? !!!
	for ii in range(10): # 10 random levels
		# Reload level with new seed
		reload_current_level(false)
		# Execute the hex
		for pattern: Pattern in hex:
			hexecutor.execute_pattern(pattern)
		# Validate the level
		if not validate_level():
			# On fail, regenerate level with same seed and enable replay mode
			reload_current_level(true)
			hex_display.begin_replay(hex) # Start with given hex
			return [] # Failed
	return [hex.size(), border_score] # Passed

# Called with new patterns from grid. Executes them using hexecutor
func new_pattern_drawn(pattern: Pattern) -> void:
	hexecutor.new_pattern(pattern)

# Called with old patterns from replay. Add to grid, then execute as a replay pattern (Won't end replay mode)
func new_replay_pattern(pattern: Pattern) -> void:
	grid.draw_existing_pattern(pattern)
	hexecutor.new_pattern(pattern, true) # True so execution won't end replay mode

# Update hex_display iotas after a pattern is executed. Causes whole stack to update, but only specified spellbook items are updated.
# 9-11 for raven, sentinel, and revealed iota. Any large number to update all, for when an unknown number of items may have changed. (Like after a meta pattern)
func update_hex_display_on_execution(updated_sb_index: int = -1, updated_selection: bool = false) -> void:
	hex_display.update_stack(hexecutor.stack)
	if updated_sb_index > -1:
		if updated_sb_index < 9:
			hex_display.update_sb_item(updated_sb_index, hexecutor.caster.node.sb[updated_sb_index])
		elif updated_sb_index == 9:
			hex_display.update_sb_item(updated_sb_index, hexecutor.caster.node.ravenmind)
		elif updated_sb_index == 10:
			hex_display.update_sb_item(updated_sb_index, hexecutor.caster.node.sentinel_pos)
		elif updated_sb_index == 11:
			var revealed_iota: Variant = hexecutor.level_base.revealed_iota if hexecutor.level_base else null # level_base can be null if not in a level # !!! CHECK IF THIS IS NEEDED
			hex_display.update_sb_item(updated_sb_index, revealed_iota)
		else: # Some large number. Nuclear option for when we don't know what changed.
			hex_display.handle_update_all_iotas(hexecutor) 
	if updated_selection:
		hex_display.update_sb_selection(hexecutor.caster.node.sb_sel)


# Update hex_display iotas after the level has changed. Causes all relevant strings to be updated.
func update_hex_display_on_level_change(update_hexy: bool, is_level_puzzle: bool) -> void:
	if update_hexy:
		hex_display.handle_update_all_iotas(hexecutor)
	hex_display.set_puzzle_tool_visibility(is_level_puzzle)

# Update border size display, also located in hex_display.
func update_border_display() -> void:
	hex_display.update_border_label(grid.hex_border.border_score, grid.hex_border.perimeter, grid.hex_border.cast_score)

# Clear grid, all patterns and reset stack
func clear() -> void:
	SoundManager.play_fail() # Sound effect for clear grid
	grid.reset(false) # Soft reset, keeps previous border score
	hexecutor.reset()
	hex_display.handle_clear_grid() # Update/Clear stack display

# End replay mode, normally after player casts a pattern manually
func end_replay_mode() -> void:
	if hex_display.replay_mode:
		hex_display.end_replay()

# Player casting functions, grid toggle/control
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_grid"):
		hex_display.toggle_grid()
		return # Done
	if not Globals.player_control:
		return # Player control required
	if event is InputEventMouseButton:
		# If right click, duplicates then executes the currently selected spellbook pattern.
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Increment border score by 2 (Arbitrary, but seems fine)
			grid.hex_border.inc_cast_score(2)
			# Duplicate the spellbook iota 
			hexecutor.execute_pattern(Pattern.new("1Llllll")) # Scribe's Reflection
			# Execute the iota, with effects
			hexecutor.execute_with_effects(Pattern.new("1RrLll")) # Hermes' Gambit
			return # Done
		# If scroll wheel, cycle through spellbook patterns (Down for increment, up for decrement)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Increment border score by 1 (Again, arbitrary)
			grid.hex_border.inc_cast_score(1)
			# Increment spellbook
			hexecutor.caster.node.inc_sb()
			# Update sb selection in ui
			hex_display.update_sb_selection(hexecutor.caster.node.sb_sel)
			# Play a sound
			SoundManager.play_segment()
			return # Done
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Increment border score by 1
			grid.hex_border.inc_cast_score(1)
			# Decrement spellbook
			hexecutor.caster.node.dec_sb()
			# Update sb selection in ui
			hex_display.update_sb_selection(hexecutor.caster.node.sb_sel)
			# Play a sound
			SoundManager.play_segment()
			return # Done

# Close game button
func _on_close_game_pressed() -> void:
	get_tree().quit()
