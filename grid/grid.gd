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

var points_dict: Dictionary = {} # Fancy dictionary to quickly get a grid point when given a Vector2i. (Not all ids exist, thus dictionary.)
var cur_points: Array = [] # List to store points in the current pattern (Ordered first to latest)
var line: Line2D = null # The line being drawn
# The shader + gradient used for the line being cast
static var line_scene: PackedScene = preload("res://resources/shaders/cast_line/cast_line.tscn")
static var line_gradient_casting: GradientTexture1D = preload("res://resources/shaders/cast_line/gradient_textures/casting.tres") # Drawing color
static var line_gradient_dragging: GradientTexture1D = preload("res://resources/shaders/cast_line/gradient_textures/meta.tres") # Dragging color
static var line_gradient_collision: GradientTexture1D = preload("res://resources/shaders/cast_line/gradient_textures/fail.tres") # Invalid position while dragging
@onready var mouse_line_color: Color = line_gradient_casting.gradient.get_color(line_gradient_casting.gradient.get_point_count() - 1)
var mouse_line: Line2D = null # The line being drawn between last point and mouse
var hex_border: Hex_Border = null # The border around the patterns drawn
var patterns: Array = [] # List of patterns, type Pattern. (Mainly for deletion afterwards)

# Drag logic variables
var dragging: bool = false # If a pattern is being dragged
var drag_pattern: Pattern = null # The pattern being dragged. (Access to points via pattern_on_grid)
var drag_point_index: int = 0 # The index of the point in the pattern that dragging started on. Used as "center" point.
var drag_old_gradient: GradientTexture1D = null # The gradient texture of the line before dragging (Will be updated during drag, and restored after)
var drag_pattern_hovered_points: Array = [] # Points that are hovered by the pattern being dragged. May contain duplicates.
var drag_new_pos_is_valid: bool = false # If the new position of the currently dragged pattern is valid

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
			points_dict[Vector2i(ii - (jj/2), jj)] = point
	
	# Prepare node size
	grid_area_shape.shape.size = NODEAREA
	grid_area_shape.position = NODEAREA / 2
	backdrop.size = NODEAREA

	# Editor mode can complain about a few things, this prevents that.
	if not Engine.is_editor_hint():
		# Prepare Line2D
		line = line_scene.instantiate()
		line.prep_line() # Creates material duplicate
		line.material.set_shader_parameter("gradient_texture", line_gradient_casting)
		add_child(line)
		
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
		# On mouse up, either send drawn pattern to be executed, or stop dragging.
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == false:
			if dragging:
				place_dragged_pattern()
			else:
				send_pattern()
			return
		# Clear hexecutor/grid etc on right click
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			# Don't clear if grid.cur_points is not empty (Pattern in progress)
			if cur_points.size() == 0:
				main_scene.clear() # Clear grid, but also related gui and hexecutor
			return

# Also handle mouse up on grid exit.
func _on_grid_area_2d_mouse_exited() -> void:
	if dragging:
		place_dragged_pattern()
	else:
		send_pattern()

# On every frame, update the mouse_line to go between the latest point and the mouse
# If cur_points is empty, mouse_line is hidden
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Handle dragging
	if dragging:
		var grab_pos: Vector2 = drag_pattern.pattern_on_grid.grid_line2d.points[drag_point_index]
		drag_pattern.pattern_on_grid.grid_line2d.position = to_local(get_global_mouse_position()) - grab_pos # Move pattern to mouse
	# Handle extra drawing line for mouse
	if len(cur_points) > 0:
		if mouse_line == null:
			mouse_line = Line2D.new()
			mouse_line.width = 3
			# Set line color last color of line_gradient_casting
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

# Handle point input
func on_point(point: Grid_Point) -> void:
	# If currently dragging a pattern, update hover points
	if dragging:
		# Free old hovered points
		for old_point: Grid_Point in drag_pattern_hovered_points:
			if old_point.state == Grid_Point.State.HOVERED: # Avoid toggling state if it's reserved
				old_point.state = Grid_Point.State.FREE
		drag_pattern_hovered_points = []
		# Get a new list of hovered points, by checking the coord id distance between the dragged pattern point and the calling point
		var drag_points: Array = drag_pattern.pattern_on_grid.grid_points
		var drag_point: Grid_Point = drag_points[drag_point_index]
		var dx: int = point.x_id - drag_point.x_id
		var dy: int = point.y_id - drag_point.y_id
		var position_is_valid: bool = true
		# Create a new list of points by adding the dx and dy to each point in the pattern, and using the points_dict to get the point
		for d_point: Grid_Point in drag_points:
			var new_coord: Vector2i = Vector2i(d_point.x_id + dx, d_point.y_id + dy)
			if points_dict.has(new_coord): # Point exists in grid
				var new_point: Grid_Point = points_dict[new_coord]
				drag_pattern_hovered_points.push_back(new_point) # Save the point for later
				if new_point.is_in_use(): # If OTHER pattern exists here, don't allow it to be placed
					position_is_valid = false
			else: # Pattern is out of bounds, don't allow it to be placed
				position_is_valid = false
		# Update state of hovered points
		for new_point: Grid_Point in drag_pattern_hovered_points:
			if new_point.state == Grid_Point.State.FREE: # Don't override reserved points
				new_point.state = Grid_Point.State.HOVERED
		# Update line color based on position validity
		drag_new_pos_is_valid = position_is_valid
		if position_is_valid:
			drag_pattern.pattern_on_grid.grid_line2d.material.set_shader_parameter("gradient_texture", line_gradient_dragging)
		else:
			drag_pattern.pattern_on_grid.grid_line2d.material.set_shader_parameter("gradient_texture", line_gradient_collision)
		return # Done!

	# If not drawing OR dragging, but just clicked a point that contains a pattern, start dragging it.
	if point.is_in_use():
		if len(cur_points) > 0:
			return # Don't allow dragging if a pattern is being drawn.
		for pattern: Pattern in patterns:
			if point in pattern.pattern_on_grid.grid_points:
				drag_pattern = pattern
				dragging = true
				var drag_points: Array = drag_pattern.pattern_on_grid.grid_points
				# Save the index of the clicked point in the pattern
				drag_point_index = drag_points.find(point)
				# Set all points in the pattern to reserved
				for d_point: Grid_Point in drag_points:
					d_point.state = Grid_Point.State.RESERVED
				# Save the current gradient texture, then set the new one
				drag_old_gradient = drag_pattern.pattern_on_grid.grid_line2d.material.get_shader_parameter("gradient_texture")
				drag_pattern.pattern_on_grid.grid_line2d.material.set_shader_parameter("gradient_texture", line_gradient_dragging)
				return # No need to do anything else.
		if !dragging:
			printerr("Point is in use, but no pattern found. Coordinates: " + str(point.x_id) + ", " + str(point.y_id))
			return # Do nothing if no pattern found

	# Otherwise, (So also point not in use,) run drawing logic with calling point (Trying desperately to split this function up. May do so more later.)
	on_point_draw(point)

# Drawing logic for on_point
func on_point_draw(point: Grid_Point) -> void:
	var cur_length: int = len(cur_points)
	var latest_point: Grid_Point = null # The latest point in cur_points. Used in multiple checks

	if cur_length > 0: # Get the latest/last used point in cur_points, if it exists
		latest_point = cur_points[-1]
		if latest_point == point: # If latest point IS the calling point, do nothing.
			return

	# Checks related to distance require at least 1 point in cur_points.
	if cur_length >= 1:
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
			var popped_point: Grid_Point = cur_points.pop_back() # Remove the latest point from cur_points
			if not (popped_point in cur_points):
				popped_point.state = Grid_Point.State.FREE # Undo DRAWING state if not being used anymore
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
	point.state = Grid_Point.State.DRAWING # Set point state, showing it's being used to draw
	line.add_point(point.position)
	line.material.set_shader_parameter("segments", line.get_point_count() - 1.0) # Update shader segments

	# Update hex border
	update_hex_border(point)

# Update the hex border with the given point, or create it if it's the first point.
func update_hex_border(point: Grid_Point) -> void:
	# If this is the first point ever, create the hex border
	if hex_border.line.get_point_count() == 0:
		hex_border.create_border(point)
	# Otherwise, update the hex border
	else:
		hex_border.expand_border(point)

# Regenerate the hex border completely, based on the current patterns being displayed.
# Should be used when a pattern is moved, or any situation where the border may shrink unpredictably. (Note, growing is fine. Only use if shrinking.)
func regenerate_hex_border() -> void:
	hex_border.reset(false) # Clear border, but do not update score.
	for pattern: Pattern in patterns:
		for point: Grid_Point in pattern.pattern_on_grid.grid_points:
			update_hex_border(point)

# Sends the created pattern to hexecutor via main_scene (Unless it's a single point)
func send_pattern() -> void:
	if cur_points.size() == 0:
		return # Do nothing
	if cur_points.size() == 1:
		line.clear_points()
		line.material.set_shader_parameter("segments", 0.0) # Update shader segments
		hex_border.undo() # Initial click could have changed border
	else: # Create, display on grid and save reference, send pattern, then reset line.
		var pattern: Pattern = Pattern.new(Pattern.calc_p_code(cur_points))
		var pattern_on_grid: Pattern_On_Grid = pattern.create_on_grid(cur_points)
		add_child(pattern_on_grid) # Add pattern_on_grid to scene via this grid
		patterns.push_back(pattern) # Pattern now contains the pattern_on_grid, so only need to keep track of pattern
		main_scene.new_pattern_drawn(pattern)
		line.clear_points() # Ready for next pattern
		line.material.set_shader_parameter("segments", 0.0) # Update shader segments
	cur_points = [] # New list, don't clear the old one
	hex_border.clear_history() # Clear history

# Place the dragged pattern on the grid if the new position is valid, or reset if not.
func place_dragged_pattern() -> void:
	# Restore old gradient texture
	drag_pattern.pattern_on_grid.grid_line2d.material.set_shader_parameter("gradient_texture", drag_old_gradient)
	# Stop following mouse
	drag_pattern.pattern_on_grid.grid_line2d.position = Vector2.ZERO
	if drag_new_pos_is_valid: # Place in new position
		# Free reserved points
		for old_point: Grid_Point in drag_pattern.pattern_on_grid.grid_points:
			old_point.state = Grid_Point.State.FREE
		# Take new points
		for new_point: Grid_Point in drag_pattern_hovered_points:
			new_point.state = Grid_Point.State.TAKEN
		# Update pattern line points, and grid point list
		for ii in range(drag_pattern.pattern_on_grid.grid_points.size()):
			drag_pattern.pattern_on_grid.grid_line2d.set_point_position(ii, drag_pattern_hovered_points[ii].position)
			drag_pattern.pattern_on_grid.grid_points[ii] = drag_pattern_hovered_points[ii]
		# Regenerate hex border
		regenerate_hex_border()
	else: # Reset to old position
		# Clear hovered points
		for old_point: Grid_Point in drag_pattern_hovered_points:
			if old_point.state == Grid_Point.State.HOVERED: # Only reset hovered points
				old_point.state = Grid_Point.State.FREE 
		# Set all points in the pattern to used again
		for d_point: Grid_Point in drag_pattern.pattern_on_grid.grid_points:
			d_point.state = Grid_Point.State.TAKEN
	# Cleanup
	dragging = false
	drag_pattern = null

# Given an existing pattern (May not be displayed yet), draw it on the grid.
# Ignores collision checks for other on_grid patterns, and overwrites any existing pattern_on_grid that this pattern may have.
func draw_existing_pattern(pattern: Pattern) -> void:
	var p_grid_points: Array = p_code_to_points(pattern.p_code, pattern.grid_location)
	var pattern_on_grid: Pattern_On_Grid = pattern.create_on_grid(p_grid_points)
	add_child(pattern_on_grid) # Add pattern_on_grid to scene via this grid
	patterns.push_back(pattern) # Keep track of recently added pattern

	# Update hex border with each point in the pattern (Probably a better way to do this, but ah well.)
	for point: Grid_Point in p_grid_points:
		update_hex_border(point)

# Reset grid. Optionally either update or clear border score.
func reset(hard: bool = false) -> void:
	for pattern: Pattern in patterns:
		pattern.remove_on_grid() # Clears points and line
	patterns = []
	if hard:
		hex_border.reset_hard()
	else:
		hex_border.reset()

# Given a p_code and a starting grid point coordinate, return a list of grid points that will make up the pattern.
func p_code_to_points(p_code: String, start: Vector2i) -> Array:
	var points: Array = [] # List of grid points, NOT Vector2i
	var pos: Vector2i = start # Vector2i representing a grid point
	points.push_back(points_dict[pos]) # First point is always the start point

	var dir: int = p_code.substr(0, 1).to_int() - 1 # 1 is top right, NE, which is index 0. Goes clockwise until 6 (index 5)
	match dir: # Adjust pos based on new dir
		0: pos += Vector2i(1, -1)
		1: pos += Vector2i(1, 0)
		2: pos += Vector2i(0, 1)
		3: pos += Vector2i(-1, 1)
		4: pos += Vector2i(-1, 0)
		5: pos += Vector2i(0, -1)
	points.push_back(points_dict[pos]) # Second point in direction of p_code first char

	var rest: String = p_code.substr(1)
	for cc in rest:
		match cc: # Figure out new direction
			"L": dir = posmod(dir - 2, 6)
			"l": dir = posmod(dir - 1, 6)
			"s": pass
			"r": dir = posmod(dir + 1, 6)
			"R": dir = posmod(dir + 2, 6)
		match dir: # Adjust pos based on new dir
			0: pos += Vector2i(1, -1)
			1: pos += Vector2i(1, 0)
			2: pos += Vector2i(0, 1)
			3: pos += Vector2i(-1, 1)
			4: pos += Vector2i(-1, 0)
			5: pos += Vector2i(0, -1)
		points.push_back(points_dict[pos]) # Find and add the point to the list

	return points
