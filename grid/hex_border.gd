class_name Hex_Border

# p1 - p6 of form [x, y]
var p1 # Top Right
var p2 # Clockwise
var p3
var p4
var p5
var p6

# The Line2D object to be drawn around patterns
# Get and add as child manually to whatever node should have it
var line

# A history of previous borders, used for undoing.
# Should be cleared when pattern completes.
var history = []

# The spacing between points, used when creating and resizing line
var x_space
var y_space

# Offsets for redraw function (Vector2 this time for ease of use)
var p1_offset
var p2_offset
var p3_offset
var p4_offset
var p5_offset
var p6_offset

func _init(GRIDSPACING, ROWSPACING):
	x_space = GRIDSPACING
	y_space = ROWSPACING

	line = Line2D.new()
	line.width = 1.5
	line.default_color = Color(0, 0, 0, 0.3)

	# Offsets for redraw function
	p1_offset = Vector2(x_space/4, -y_space/2)
	p2_offset = Vector2(x_space/2, 0.0)
	p3_offset = Vector2(x_space/4, y_space/2)
	p4_offset = Vector2(-x_space/4, y_space/2)
	p5_offset = Vector2(-x_space/2, 0.0)
	p6_offset = Vector2(-x_space/4, -y_space/2)

# Expand border based on the location of new point
func expand_border(point):
	# If this is the first point, warn in logs and do nothing.
	if line.get_point_count() == 0:
		print("Warning: HexBorder.new_point() called before initial border created.")
		return
	# Otherwise, find new p1-p6 that create a hexagon enclosing the new point (p7) and all previous points
	var p7_x = point.x_id
	var p7_y = point.y_id
	var p7_x_y = p7_x + p7_y

	# Initial values based on points 1-6 (See large comment later in func for details)
	# If nothing changes, we can skip redrawing the border
	var min_x = p4[0]
	var max_x = p1[0]
	var min_y = p6[1]
	var max_y = p3[1]
	var min_x_y = p5[0] + p5[1]
	var max_x_y = p2[0] + p2[1]
	var changed = false

	# Check if p7 changes any of these values
	if p7_x < min_x:
		min_x = p7_x
		changed = true
	if p7_x > max_x:
		max_x = p7_x
		changed = true
	if p7_y < min_y:
		min_y = p7_y
		changed = true
	if p7_y > max_y:
		max_y = p7_y
		changed = true
	if p7_x_y < min_x_y:
		min_x_y = p7_x_y
		changed = true
	if p7_x_y > max_x_y:
		max_x_y = p7_x_y
		changed = true
	
	# If nothing changed, then just return
	if not changed:
		history.append([]) # No change in history
		return

	# Save current border to history
	history.append([p1, p2, p3, p4, p5, p6])

	# Create new p1-p6 based on these values
	# - p1 has max x and min y
	# - p2 has max x and max xy (y = max_x_y - max_x)
	# - p3 has max y and max xy (x = max_x_y - max_y)
	# - p4 has min x and max y
	# - p5 has min x and min xy (y = min_x_y - min_x)
	# - p6 has min y and min xy (x = min_x_y - min_y)
	p1 = [max_x, min_y]
	p2 = [max_x, max_x_y - max_x]
	p3 = [max_x_y - max_y, max_y]
	p4 = [min_x, max_y]
	p5 = [min_x, min_x_y - min_x]
	p6 = [min_x_y - min_y, min_y]

	# Redraw border
	redraw()

# Create the border around the given point
func create_border(point):
	var x_id = point.x_id
	var y_id = point.y_id

	p1 = [x_id, y_id]
	p2 = [x_id, y_id]
	p3 = [x_id, y_id]
	p4 = [x_id, y_id]
	p5 = [x_id, y_id]
	p6 = [x_id, y_id]

	# Redraw border
	redraw()

# Calculates the position of a point using only x_id and y_id
func point_pos(xx, yy):
	xx += (yy / 2) # Account for slanted x axis
	var offset = 0
	if yy % 2 == 1: # If the row number is odd
		offset = x_space / 2
	return Vector2(xx * x_space + offset, yy * y_space)

# Redraw border
func redraw():
	line.clear_points()
	# Create line points p1 - p6, then p1 again to loop
	line.add_point(point_pos(p1[0], p1[1]) + p1_offset) # p1
	line.add_point(point_pos(p2[0], p2[1]) + p2_offset) # p2
	line.add_point(point_pos(p3[0], p3[1]) + p3_offset) # p3
	line.add_point(point_pos(p4[0], p4[1]) + p4_offset) # p4
	line.add_point(point_pos(p5[0], p5[1]) + p5_offset) # p5
	line.add_point(point_pos(p6[0], p6[1]) + p6_offset) # p6
	line.add_point(line.get_point_position(0)) # p1 again, using same Vector2
	
	# Print out p1-p6 in a nice format (Multiple lines)
	# print("p1: ", p1, "\n",
	# 	"p2: ", p2, "\n",
	# 	"p3: ", p3, "\n",
	# 	"p4: ", p4, "\n",
	# 	"p5: ", p5, "\n",
	# 	"p6: ", p6, "\n")

# Revert to the previous border, warning in logs if empty
func undo():
	if history.size() == 0:
		# Check if points are all the same. If they are, then reset border (No patterns on screen)
		if p1 == p2 and p2 == p3 and p3 == p4: # 1-4 are same, so 5-6 are too (Should be anyway)
			reset() # Should only happen when border just been made
		return
	var prev = history.pop_back()

	# If prev is empty, do nothing
	if prev.size() == 0:
		return

	# Else revert
	p1 = prev[0]
	p2 = prev[1]
	p3 = prev[2]
	p4 = prev[3]
	p5 = prev[4]
	p6 = prev[5]
	redraw()

# Clear history, used when pattern completes
func clear_history():
	history.clear()

# Delete border, ready to be reused.
func reset():
	line.clear_points()
