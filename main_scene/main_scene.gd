@tool
extends Node2D

# Test_level scene
#var test_level = preload("res://levels/test_level.tscn")
@onready var hexecutor = null

@export var grid: Node2D
@onready var hex_display = $HexDisplay
@export var level_container: SubViewportContainer
@onready var level_viewport = level_container.get_child(0)

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
	# Load test level
	loaded_level = scene.instantiate()
	level_viewport.add_child(loaded_level)
	# Offset by Entity.FAKE_SCALE / 2 (Due to tilemap offset)
	if Engine.is_editor_hint():
		loaded_level.position = Vector2(32, 32) # Issue getting Entity.FAKE_SCALE in editor. This may become outdated
		return # Don't update rest of scene if in editor
	else:
		loaded_level.position = Vector2(Entity.FAKE_SCALE / 2, Entity.FAKE_SCALE / 2)

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(loaded_level, loaded_level.player.entity, self)

	# Update hex_display, level desc
	update_hex_display()
	hex_display.update_level_desc_label(loaded_level.validator.desc)

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

# Validates the current level
func validate_level():
	return loaded_level.validate()

# Called with new patterns from grid. Executes them using hexecutor
func new_pattern_drawn(pattern):
	hexecutor.new_pattern(pattern)

# Update hex_display (Normally after a pattern is executed)
# Takes hexecutor to get stack/caster info etc
func update_hex_display(err_str = ""):
	hex_display.update_all_hexy(hexecutor, err_str) # Update stack display

# Update border size display, also located in hex_display.
func update_border_display():
	hex_display.update_border_label(grid.hex_border.border_score, grid.hex_border.perimeter, grid.hex_border.cast_score)

# Clear grid, all patterns and reset stack
func clear():
	grid.reset(false) # Soft reset, keeps previous border score
	hexecutor.reset()
	hex_display.update_clear_hexy() # Update/Clear stack display

# Player cast function (On right click)
# Duplicates then executes the currently selected spellbook pattern.
func _input(event):
	if not Globals.player_control:
		return # Player control required
	# If right click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Increment border score by 2 (Arbitrary, but seems fine)
		grid.hex_border.inc_cast_score(2)
		# Duplicate the spellbook iota 
		hexecutor.execute_pattern(Pattern.new("1Llllll")) # Scribe's Reflection
		# Execute the iota
		hexecutor.execute_pattern(Pattern.new("1RrLll")) # Hermes' Gambit