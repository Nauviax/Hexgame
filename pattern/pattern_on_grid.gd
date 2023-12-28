class_name Pattern_Ongrid
# This class exists to represent a pattern on the grid. It is deleted when grid is cleared.
# Pattern var should also be discarded when this is deleted, unless it is on the stack/saved somewhere.

# List of grid points that make up this pattern.
# point.in_use should be set false before deleting this pattern.
var points = []

# The Line2D object that represents this pattern.
# Held here so it can be deleted when this pattern is deleted.
var line = null

# Pattern object that this represents. Stores most data related to this pattern.
var pattern = null

# Pattern_Ongrid constructor. Takes points and line, then creates a pattern object.
func _init(point_init, line_init):
	points = point_init
	# All points are now in use.
	for pnt in points:
		pnt.in_use = true
	line = line_init

	# Create pattern object, calculating p_code from points.
	pattern = Pattern.new(Pattern_Ongrid.calc_p_code(points))

# Remove pattern from grid, freeing up all points and removing line graphic.
func remove():
	# Free up all points.
	for pnt in points:
		pnt.in_use = false
	points.clear()
	# Remove line graphic.
	line.queue_free()

# Calculates p_code from points.
static func calc_p_code(points):
	# Get the initial direction.
	var dir = get_dir(points[0], points[1])
	var dir2 = -1 # Used in for loop
	var p_code = str(dir) # The return value. Starts with a num, then letters.
	# For every other point, get the turn from the previous point.
	for ii in range(2, points.size()):
		dir2 = get_dir(points[ii-1], points[ii])
		p_code += get_turn(dir, dir2)
		dir = dir2
	return p_code
	
# Calculates the direction from point a to point b. (1-6 starting NE and going clockwise.)
static func get_dir(a, b):
	var x = b.x_id - a.x_id
	var y = b.y_id - a.y_id
	if x == 0:
		if y == 1:
			return 3
		else: # y == -1
			return 6
	elif x == 1:
		if y == 0:
			return 2
		else: # y == -1
			return 1
	else: # x == -1
		if y == 0:
			return 5
		else: # y == 1
			return 4

# Calculates the turn from direction a to direction b. (L, l, s, r, R)
# Inputs are 1-6 starting NE and going clockwise.
static func get_turn(a, b):
	var turn = b - a
	if turn < 0: # Avoid negative numbers
		turn += 6
	match turn:
		0:
			return "s"
		1:
			return "r"
		2:
			return "R"
		4:
			return "L"
		5:
			return "l"
		_:
			return null # Should never happen. (This is also the "3" case.)