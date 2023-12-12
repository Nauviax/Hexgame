@tool
extends Node2D

var PointScene = preload("res://hexlogic/grid/point.tscn")
@onready var parent_hexlogic = get_parent()

const GRIDSIZE = 16 # Amount of points in given direction
const GRIDSPACING = 16.0 # Distance between points
const ROWSPACING = GRIDSPACING * 0.866  # Distance between each row, based on X (0.866 ~= sqrt(3)/2)

var points = [] # List to store the points
var cur_points = [] # List to store points in the current pattern (Ordered first to latest)
var line = null # The line being drawn
# The gradient used for the line being cast
static var line_gradient = preload("res://hexlogic/gradients/casting.tres")
var mouse_line = null # The line being drawn between last point and mouse
var hex_border = null # The border around the patterns drawn
@onready var seg_sound = $Add_Seg # Sound effect


# Prepare *stuff*
func _ready():
	# Draw points
	for ii in range(GRIDSIZE):
		for jj in range(GRIDSIZE):
			var point = PointScene.instantiate()
			var offset = 0
			if jj % 2 == 1: # If the row number is odd
				offset = GRIDSPACING / 2
			point.position = Vector2(ii * GRIDSPACING + offset, jj * ROWSPACING) # Set the position of the point
			if not Engine.is_editor_hint():
				point.set_id(ii - (jj/2), jj) # Set the id of the point
			add_child(point)
			points.append(point)

	# Prepare Line2D
	new_line()

	# Prepare Hex border
	if not Engine.is_editor_hint():
		hex_border = Hex_Border.new(GRIDSPACING, ROWSPACING)
		add_child(hex_border.line)

# On every frame, update the mouse_line to go between the latest point and the mouse
# If cur_points is empty, mouse_line is hidden
func _process(_delta):
	if Engine.is_editor_hint():
		return
	if len(cur_points) > 0:
		if mouse_line == null:
			mouse_line = Line2D.new()
			mouse_line.width = 1
			# Set line color last color of line_gradient
			mouse_line.set_default_color(line_gradient.get_color(line_gradient.get_point_count() - 1))
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
func on_point(point):
	var cur_length = len(cur_points)

	# Check if the point is not the latest point in cur_points, or if it is already in use
	if point.in_use or (cur_length > 0 and point == cur_points[-1]):
		return # Do nothing

	var latest_point = null # The latest point in cur_points. Used in multiple checks

	# Checks related to distance require at least 1 point in cur_points.
	if cur_length >= 1:
		latest_point = cur_points[-1] # Set latest_point to the latest point in cur_points

		# Calculate difference between latest point and current point x_id and y_id
		# Point is too far if abs x or y dif is > 1, or if the abs sum is > 1 (Allow one type of diagonal)
		var x_dif = point.x_id - latest_point.x_id 
		var y_dif = point.y_id - latest_point.y_id
		if (abs(x_dif) > 1 or abs(y_dif) > 1 or abs(x_dif + y_dif) > 1):
			return # Do nothing
	
	# Checks related to previously used points require at least 2 points in cur_points.
	if cur_length >= 2:
		# Check if the point is the previous point (Go back one)
		if cur_points[-2] == point:
			seg_sound.play() # Sound effect
			cur_points.pop_back() # Remove the latest point from cur_points
			line.remove_point(line.get_point_count() - 1)
			hex_border.undo() # Revert to previous border
			return
		
		# Tricky one, to allow line to use points multiple times without sharing the same point pairs.
		# Foreach point (forPoint) in cur_points EXCEPT the latest, check if the point is the same as the latest.
		# If it IS, check that point is NOT the same point as the one before and after forPoint.
		# If it IS, return. Else continue.
		for ii in range(0, len(cur_points) - 1):
			var for_point = cur_points[ii]
			if for_point == latest_point:
				if cur_points[ii - 1] == point or cur_points[ii + 1] == point:
					return

	# All checks done. Add point to cur_points and line
	seg_sound.play() # Sound effect
	cur_points.append(point)
	line.add_point(point.position)
	#print("X = %d, Y = %d" % [point.x_id, point.y_id])	

	# If this is the first point ever, create the hex border
	if hex_border.line.get_point_count() == 0:
		hex_border.create_border(point)
	# Otherwise, update the hex border
	else:
		hex_border.expand_border(point)

# Sends the created pattern to parent hexlogic (Unless it's a single point)
func send_pattern():
	if cur_points.size() <= 1:
		line.clear_points()
		hex_border.undo() # Initial click could have changed border
	else: # Send pattern and prepare new line.
		parent_hexlogic.new_pattern(cur_points, line)
		new_line()
	cur_points = [] # New list, don't clear the old one
	hex_border.clear_history() # Clear history


# Set line to a new instance of Line2D
func new_line():
	line = Line2D.new()
	line.width = 1
	line.gradient = line_gradient
	add_child(line)
