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
	# Offset by Entity.FAKE_SCALE / 2 (Due to tilemap offset)
	level.position = Vector2(Entity.FAKE_SCALE / 2, Entity.FAKE_SCALE / 2)

	# Prepare hexecutor with level info
	hexecutor = Hexecutor.new(level, level.player.entity, self)

	# Update hex_display
	update_hex_display()

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
