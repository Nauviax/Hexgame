@tool
extends Node2D

# Children
@onready var grid = $Grid
@onready var stack_disp = $StackDisp

# The stack
var stack = []

# List of patterns
var patterns = []

# Consideration Mode
# If true, the next executed pattern will be saved to the stack as a pattern.
# This takes priority over introspection mode, though still appends to Metalist. It can be used to add retrospection to a list.
# Adding consideration to the list requires two considerations in a row.
var consideration_mode = false

# Introspection Mode
# If > 0, executed patterns are instead saved to the Pattern_Metalist at the top of the stack.
# If the top of the stack is not a Pattern_Metalist, throw a Godot error (Not bad_iota)
# Incremented/Decremented via Introspection and Retrospection respectively.
var introspection_depth = 0

# The entity casting this hex (Normally the player)
# This should be set after instantiation of the hexlogic scene!
var caster = null

# A reference to the map the caster is a part of. Specifically, the Map_Info object.
# Used to get entities and other map data for certian patterns.
var map = null

# Handle initialization (More manual than _init but oh well.)
func init(caster, map):
	self.caster = caster
	self.map = map

# Handle input
func _input(event):
	if event is InputEventMouseButton:
		# Tell grid to send pattern on mouse up
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == false:
			grid.send_pattern()
			return
		# Clear on right click
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			# Don't clear if grid.cur_points is not empty (Pattern in progress)
			if grid.cur_points.size() == 0:
				clear()
			return
		
# Recieve a list of points from the grid, along with a Line2D
# Creates a new pattern from the points, tries to validate it, then executes it
func new_pattern(points, line):
	var pattern = Pattern.new(points, line)
	patterns.append(pattern)
	execute_pattern(pattern)

# Executes a given pattern
func execute_pattern(pattern):
	var return_string = ""
	if consideration_mode: # Single meta-pattern mode, see var declaration.
		if stack.size() > 0 and stack[-1] is Pattern_Metalist:
			stack[-1].patterns.push_back(pattern)
		else:
			stack.push_back(pattern) # Append to stack with no list
		consideration_mode = false
	elif introspection_depth > 0 and pattern.name != "Consideration": # Multi meta-pattern mode, see var declaration.
		if stack.size() > 0 and stack[-1] is Pattern_Metalist:
			return_string = stack[-1].add_pattern(self, pattern)
		else:
			printerr("ERROR: Introspection mode enabled, but top of stack is not a Pattern_Metalist!")
			return
	else: # Default mode, just execute the pattern
		return_string = pattern.execute(self)
	stack_disp.update_stack(return_string) # Update stack display
	scan_stack() # Debugging, comment out when not needed anymore

# Clear all patterns and reset stack
func clear():
	# Stack
	stack = []
	caster.ravenmind = null # Clear ravenmind
	stack_disp.update_stack("Grid and stack cleared!") # Update stack display
	# Meta-state
	introspection_depth = 0
	consideration_mode = false
	# Patterns
	for pattern in patterns:
		pattern.delete()
	patterns = []
	# Grid
	grid.hex_border.reset()

# Debugging function, should not run in final product.
# Ensures no ints enter the stack. Will warn in console and throw if it does.
# Also ensures no duplicate array references are in the stack.
func scan_stack():
	var array_list = []
	for item in stack:
		if item is int:
			printerr("WARNING: Int found in stack!")
		if item is Array:
			for arr in array_list:
				if is_same(arr, item): # By reference, not the same as ==
					printerr("WARNING: Duplicate array reference found in stack!")
			array_list.append(item)

