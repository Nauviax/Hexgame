@tool
extends Node2D

# Test_level scene
var test_level = preload("res://levels/test_level.tscn")
@onready var hexecutor = null

@export var grid_path: NodePath # Set in Inspector
@onready var grid = get_node(grid_path) # $Grid
@onready var hex_display = $HexDisplay
@export var level_control_path: NodePath # Set in Inspector also
@onready var level_control = get_node(level_control_path)

# For now, just load the test_level scene and prepare hexecutor
func _ready():
	# Load test level
	var level = test_level.instantiate()
	level_control.add_child(level)

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(level.level_info, level.level_info.player, self)

	# Update hex_display
	update_hex_display()

# Handle input
func _input(event):
	if event is InputEventMouseButton:
		# Tell grid to send pattern on mouse up
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == false:
			grid.send_pattern()
			return
		# Clear hexecutor/grid etc on right click
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			# Don't clear if grid.cur_points is not empty (Pattern in progress)
			if grid.cur_points.size() == 0:
				clear()
			return

# Called with new patterns from grid. Executes them using hexecutor
func new_pattern_drawn(pattern):
	hexecutor.new_pattern(pattern)

# Update hex_display (Normally after a pattern is executed)
# Takes hexecutor to get stack/caster info etc
func update_hex_display(err_str = ""):
	hex_display.update_all(hexecutor, err_str) # Update stack display

# Clear all patterns and reset stack
func clear():
	hexecutor.reset()
	hex_display.update_clear() # Update/Clear stack display
	for pattern_og in grid.patterns:
		pattern_og.remove()
	grid.patterns = []
	grid.hex_border.reset()

# Spellbook button handlers, possibly redo later (!!!)
func spellbook_LR(left):
	if left:
		hexecutor.caster.dec_sb()
	else:
		hexecutor.caster.inc_sb()
	hex_display.update_sb_label(hexecutor.caster)
