@tool
extends Node2D

var point_scene: PackedScene = preload("res://grid/point.tscn")
@export var main_scene: Node2D # Set in Inspector

@onready var grid_area_shape: CollisionShape2D = $GridArea2D/CollisionShape2D # The mouse scan area
@onready var backdrop: ColorRect = $ColorRect

const GRIDSIZE_X: int = 22 # Amount of points along X axis
const GRIDSIZE_Y: int = 20 # Amount of points along Y axis
const GRIDSPACING: float = 64.0 # Distance between points
const ROWSPACING: float = GRIDSPACING * 0.866  # Distance between each row, based on X (0.866 ~= sqrt(3)/2)
const GRIDOFFSET = Vector2(8, 12) # Offset of the grid from the top left corner of the screen
const NODEAREA = Vector2(1370, 1080) # Area that grid is expected to take up

var points: Array = [] # List to store the points
var cur_points: Array = [] # List to store points in the current pattern (Ordered first to latest)
var line: Line2D = null # The line being drawn
# The shader + gradient used for the line being cast
static var line_scene: PackedScene = preload("res://resources/shaders/cast_line/cast_line.tscn")
static var line_gradient: GradientTexture1D = preload("res://resources/shaders/cast_line/gradient_textures/casting.tres")
@onready var mouse_line_color: Color = line_gradient.gradient.get_color(line_gradient.gradient.get_point_count() - 1)
var mouse_line: Line2D = null # The line being drawn between last point and mouse
var hex_border: Hex_Border = null # The border around the patterns drawn
var patterns: Array = [] # List of patterns (Mainly for deletion afterwards)

# Prepare *stuff*
func _ready() -> void:
	# Draw points
	for ii in range(GRIDSIZE_X):
		for jj in range(GRIDSIZE_Y):
			var point: Grid_Point = point_scene.instantiate()
			var x_offset: float = 0
			if jj % 2 == 1: # If the row number is odd
				x_offset = GRIDSPACING / 2
			point.position = GRIDOFFSET + Vector2(ii * GRIDSPACING + x_offset, jj * ROWSPACING) # Set the position of the point
			if not Engine.is_editor_hint():
				point.set_id(ii - (jj/2), jj) # Set the id of the point
			add_child(point)
			points.append(point)
	
	# Prepare node size
	grid_area_shape.shape.size = NODEAREA
	grid_area_shape.position = NODEAREA / 2
	backdrop.size = NODEAREA

	# Editor mode can complain about a few things, this prevents that.
	if not Engine.is_editor_hint():
		# Prepare Line2D
		new_line()
		
		# Prepare Hex border
		hex_border = Hex_Border.new(GRIDSPACING, ROWSPACING, main_scene)
		hex_border.line.position = GRIDOFFSET # Offset hex_border to match the grid
		add_child(hex_border.line)

# Handle input for grid
# Don't allow input if player_control is true
func _on_grid_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Check player control
	if Globals.player_control:
		return
	# Mouse input
	if event is InputEventMouseButton:
		# Tell grid to send pattern on mouse up
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == false:
			send_pattern()
			return
		# Clear hexecutor/grid etc on right click
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			# Don't clear if grid.cur_points is not empty (Pattern in progress)
			if cur_points.size() == 0:
				SoundManager.play_fail() # Sound effect
				main_scene.clear() # Clear grid, but also related gui and hexecutor
			return

# Also send pattern on mouse exit
func _on_grid_area_2d_mouse_exited() -> void:
	send_pattern()

# On every frame, update the mouse_line to go between the latest point and the mouse
# If cur_points is empty, mouse_line is hidden
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if len(cur_points) > 0:
		if mouse_line == null:
			mouse_line = Line2D.new()
			mouse_line.width = 3
			# Set line color last color of line_gradient
			mouse_line.set_default_color(mouse_line_color)
			add_child(mouse_line)
			mouse_line.add_point(cur_points[-1].position)
			mouse_line.add_point(mouse_line.to_local(get_global_mouse_position()))
		# Modify the last point to follow the mouse
		mouse_line.set_point_position(0, cur_points[-1].position)
		mouse_line.set_point_position(1, mouse_line.to_local(get_global_mouse_position()))
	else:
		if mouse_line != null:
			mouse_line.clear_points()
			mouse_line.queue_free()
			mouse_line = null

# Handle pattern drawing
func on_point(point: Grid_Point) -> void:
	var cur_length: int = len(cur_points)

	# Check if the point is not the latest point in cur_points, or if it is already in use
	if point.in_use or (cur_length > 0 and point == cur_points[-1]):
		return # Do nothing

	var latest_point: Grid_Point = null # The latest point in cur_points. Used in multiple checks

	# Checks related to distance require at least 1 point in cur_points.
	if cur_length >= 1:
		latest_point = cur_points[-1] # Set latest_point to the latest point in cur_points

		# Calculate difference between latest point and current point x_id and y_id
		# Point is too far if abs x or y dif is > 1, or if the abs sum is > 1 (Allow one type of diagonal)
		var x_dif: int = point.x_id - latest_point.x_id 
		var y_dif: int = point.y_id - latest_point.y_id
		if (abs(x_dif) > 1 or abs(y_dif) > 1 or abs(x_dif + y_dif) > 1):
			return # Do nothing
	
	# Checks related to previously used points require at least 2 points in cur_points.
	if cur_length >= 2:
		# Check if the point is the previous point (Go back one)
		if cur_points[-2] == point:
			SoundManager.play_segment() # Sound effect
			cur_points.pop_back() # Remove the latest point from cur_points
			line.remove_point(line.get_point_count() - 1)
			line.material.set_shader_parameter("segments", line.get_point_count() - 1.0) # Update shader segments
			hex_border.undo() # Revert to previous border
			return
		
		# Tricky one, to allow line to use points multiple times without sharing the same point pairs.
		# Foreach point (forPoint) in cur_points EXCEPT the latest, check if the point is the same as the latest.
		# If it IS, check that point is NOT the same point as the one before and after forPoint.
		# If it IS, return. Else continue.
		for ii in range(0, len(cur_points) - 1):
			var for_point: Grid_Point = cur_points[ii]
			if for_point == latest_point:
				if cur_points[ii - 1] == point or cur_points[ii + 1] == point:
					return

	# All checks done. Add point to cur_points and line
	SoundManager.play_segment() # Sound effect
	cur_points.append(point)
	line.add_point(point.position)
	line.material.set_shader_parameter("segments", line.get_point_count() - 1.0) # Update shader segments

	# If this is the first point ever, create the hex border
	if hex_border.line.get_point_count() == 0:
		hex_border.create_border(point)
	# Otherwise, update the hex border
	else:
		hex_border.expand_border(point)

# Sends the created pattern to hexecutor via main_scene (Unless it's a single point)
func send_pattern() -> void:
	if cur_points.size() == 0:
		return # Do nothing
	if cur_points.size() == 1:
		line.clear_points()
		line.material.set_shader_parameter("segments", 0.0) # Update shader segments
		hex_border.undo() # Initial click could have changed border
	else: # Create and send pattern, (And save result to list here) then prepare new line.
		var pattern: Pattern_Ongrid = Pattern_Ongrid.new(cur_points, line)
		patterns.push_back(pattern)
		main_scene.new_pattern_drawn(pattern)
		new_line()
	cur_points = [] # New list, don't clear the old one
	hex_border.clear_history() # Clear history

# Set line to a new instance of Line2D
func new_line() -> void:
	line = line_scene.instantiate()
	line.prep_line() # Creates material duplicate
	line.material.set_shader_parameter("gradient_texture", line_gradient)
	add_child(line)

# Reset grid. Optionally either update or clear border score.
func reset(hard: bool = false) -> void:
	for pattern_on_grid: Pattern_Ongrid in patterns:
		pattern_on_grid.remove() # Clears points and line
	patterns = []
	if hard:
		hex_border.reset_hard()
	else:
		hex_border.reset()
