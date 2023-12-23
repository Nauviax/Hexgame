@tool
extends Node2D

# Test_level scene
#var test_level = preload("res://levels/test_level.tscn")
@onready var hexecutor = null

@export var grid_path: NodePath # Set in Inspector
@onready var grid = get_node(grid_path) # $Grid
@onready var hex_display = $HexDisplay
@export var level_control_path: NodePath # Set in Inspector also
@onready var level_control = get_node(level_control_path)

var loaded_level = null # Currently loaded level (Child of level_control)
var level_list = [] # List of level scenes that can be loaded. (Scenes, not instantiated)
var level_current_index = 0 # Index of currently loaded level in level_list

# For now, just load the test_level scene and prepare hexecutor
func _ready():
	# Prepare level_list
	level_list.push_back(preload("res://levels/test_level/level.tscn"))
	level_list.push_back(preload("res://levels/reveal_iota/level.tscn"))
	level_list.push_back(preload("res://levels/bool_sort/level.tscn"))
	load_next_level(false) # False as nothing to unload yet

# Unloads the current level and loads the next one
func load_next_level(unload = true):
	if unload:
		# Unload current level
		loaded_level.queue_free()
		loaded_level = null
		# Increment level index, loop back to 0 if at end
		level_current_index += 1
		if level_current_index >= level_list.size():
			level_current_index = 0
		# Clear grid
		grid.reset(true) # Hard reset, clears border score

	# Load test level
	loaded_level = level_list[level_current_index].instantiate()
	level_control.add_child(loaded_level)
	# Offset by Entity.FAKE_SCALE / 2 (Due to tilemap offset)
	if Engine.is_editor_hint():
		loaded_level.position = Vector2(32, 32) # Issue getting Entity.FAKE_SCALE in editor. This may become outdated
	else:
		loaded_level.position = Vector2(Entity.FAKE_SCALE / 2, Entity.FAKE_SCALE / 2)

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(loaded_level, loaded_level.player.entity, self)

	# Update hex_display
	update_hex_display()

	# Update level description
	hex_display.update_level_desc_label(loaded_level.validator.desc)

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
	hex_display.update_border_label(grid.hex_border.border_score, grid.hex_border.perimeter)

# Clear grid, all patterns and reset stack
func clear():
	grid.reset(false) # Soft reset, keeps previous border score
	hexecutor.reset()
	hex_display.update_clear_hexy() # Update/Clear stack display

# Spellbook button handlers, possibly redo later (!!!)
func spellbook_LR(left):
	if left:
		hexecutor.caster.dec_sb()
	else:
		hexecutor.caster.inc_sb()
	hex_display.update_sb_label(hexecutor.caster)
