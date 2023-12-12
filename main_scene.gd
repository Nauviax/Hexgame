@tool
extends Node2D

# Test_level scene
var test_level = preload("res://levels/test_level.tscn")
@onready var hexecutor = null
@onready var grid = $Grid
@onready var hex_disp = $HexDisp

# For now, just load the test_level scene and prepare hexecutor
func _ready():
	# Load test level
	var level = test_level.instantiate()
	add_child(level)

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(level.level_info, level.level_info.player, self)

	# Update hex_disp
	update_hex_disp()

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

# Update hex_disp (Normally after a pattern is executed)
# Takes hexecutor to get stack/caster info etc
func update_hex_disp(err_str = ""):
	hex_disp.update_all(hexecutor, err_str) # Update stack display

# Clear all patterns and reset stack
func clear():
	# Stack
	hexecutor.stack = []
	hexecutor.caster.ravenmind = null # Clear ravenmind
	hex_disp.update_clear() # Update/Clear stack display
	# Meta-state
	hexecutor.introspection_depth = 0
	hexecutor.consideration_mode = false
	# Patterns and Grid
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
	hex_disp.update_sb_label(hexecutor.caster)
