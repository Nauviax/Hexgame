class_name Hex_Border

# Reference to main scene, to request UI updates (For now just border score)
var main_scene: Main_Scene

# p1 - p6 of form Vector2i
# Note these are ids, not positions
var p1: Vector2i # Top Right
var p2: Vector2i # Clockwise
var p3: Vector2i
var p4: Vector2i
var p5: Vector2i
var p6: Vector2i

# The Line2D object to be drawn around patterns
# Get and add as child manually to whatever node should have it
var line: Line2D

# Perimeter of the border, recalculated on redraw
var perimeter: int = 0

# Border score, equal to the sum of cleared hex border perimeters.
# Does NOT include current border. (Add perimeter for final score)
var border_score: int = 0

# Cast score, an arbitrary score representing player casts. Added to border score for final score.
# On grid reset, cast score is added to border score and reset to 0.
var cast_score: int = 0

# A history of previous borders, used for undoing. (Can contain empty arrays, which are effectively nulls)
# Should be cleared when pattern completes.
var history: Array = []

# The spacing between points, used when creating and resizing line
var x_space: float
var y_space: float

# Offsets for redraw function (Vector2 this time for ease of use)
var p1_offset: Vector2
var p2_offset: Vector2
var p3_offset: Vector2
var p4_offset: Vector2
var p5_offset: Vector2
var p6_offset: Vector2

func _init(GRIDSPACING: float, ROWSPACING: float, main_scene: Main_Scene) -> void:
	x_space = GRIDSPACING
	y_space = ROWSPACING
	self.main_scene = main_scene

	line = Line2D.new()
	line.width = 1.5
	line.default_color = Color(0, 0, 0, 0.3)
	line.closed = true # Loop back to p1

	# Offsets for redraw function
	p1_offset = Vector2(x_space/4, -y_space/2)
	p2_offset = Vector2(x_space/2, 0.0)
	p3_offset = Vector2(x_space/4, y_space/2)
	p4_offset = Vector2(-x_space/4, y_space/2)
	p5_offset = Vector2(-x_space/2, 0.0)
	p6_offset = Vector2(-x_space/4, -y_space/2)

# Expand border based on the location of new point
func expand_border(point: Grid_Point) -> void:
	# If this is the first point, warn in logs and do nothing.
	if line.get_point_count() == 0:
		printerr("Warning: HexBorder.new_point() called before initial border created.")
		return
	# Otherwise, find new p1-p6 that create a hexagon enclosing the new point (p7) and all previous points
	var p7_x: int = point.x_id
	var p7_y: int = point.y_id
	var p7_x_y: int = p7_x + p7_y

	# Initial values based on points 1-6 (See large comment later in func for details)
	# If nothing changes, we can skip redrawing the border
	var min_x: int = p4.x
	var max_x: int = p1.x
	var min_y: int = p6.y
	var max_y: int = p3.y
	var min_x_y: int = p5.x + p5.y
	var max_x_y: int = p2.x + p2.y
	var changed: bool = false

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
		history.append([]) # No change in history, append empty array
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
	p1 = Vector2i(max_x, min_y)
	p2 = Vector2i(max_x, max_x_y - max_x)
	p3 = Vector2i(max_x_y - max_y, max_y)
	p4 = Vector2i(min_x, max_y)
	p5 = Vector2i(min_x, min_x_y - min_x)
	p6 = Vector2i(min_x_y - min_y, min_y)

	# Redraw border
	redraw()

# Create the border around the given point
func create_border(point: Grid_Point) -> void:
	var x_id: int = point.x_id
	var y_id: int = point.y_id

	p1 = Vector2i(x_id, y_id)
	p2 = Vector2i(x_id, y_id)
	p3 = Vector2i(x_id, y_id)
	p4 = Vector2i(x_id, y_id)
	p5 = Vector2i(x_id, y_id)
	p6 = Vector2i(x_id, y_id)

	# Redraw border
	redraw()

# Calculates the position of a point using given id vector
func point_pos(vect: Vector2i) -> Vector2:
	var xx: int = vect.x
	var yy: int = vect.y
	xx += (yy / 2) # Account for slanted x axis
	var offset: float = 0
	if yy % 2 == 1: # If the row number is odd
		offset = x_space / 2
	return Vector2(xx * x_space + offset, yy * y_space)

# Redraw border
func redraw() -> void:
	line.clear_points()
	# Create line points p1 - p6
	line.add_point(point_pos(p1) + p1_offset)
	line.add_point(point_pos(p2) + p2_offset)
	line.add_point(point_pos(p3) + p3_offset)
	line.add_point(point_pos(p4) + p4_offset)
	line.add_point(point_pos(p5) + p5_offset)
	line.add_point(point_pos(p6) + p6_offset)
	
	# Calculate perimeter (Rounded down to int)
	perimeter = int(calc_dist_v2i(p1, p2) + calc_dist_v2i(p2, p3) + calc_dist_v2i(p3, p4) + calc_dist_v2i(p4, p5) + calc_dist_v2i(p5, p6) + calc_dist_v2i(p6, p1))
	
	# Redraw
	main_scene.update_border_display()

# Calculates distance between two Vector2i, because Vector2i doesn't have a .distance_to method (!!! Look into other ways of doing this!)
func calc_dist_v2i(p1: Vector2i, p2: Vector2i) -> float:
	return sqrt((p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2)

# Revert to the previous border, warning in logs if empty
func undo() -> void:
	if history.size() == 0:
		# Check if points are all the same. If they are, then reset border (No patterns on screen)
		if p1 == p2 and p2 == p3 and p3 == p4: # 1-4 are same, so 5-6 are too (Should be anyway)
			reset(false) # Should only happen when border just been made
		return
	var prev: Array = history.pop_back()

	# If prev is empty, (null,) do nothing
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

# Allows manual score inflation via cast score, to prevent manual r-click casting being completely free
func inc_cast_score(amnt: int) -> void:
	cast_score += amnt
	main_scene.update_border_display()

# Return total border score
func get_score() -> int:
	return border_score + perimeter + cast_score

# Clear history, used when pattern completes
func clear_history() -> void:
	history.clear()

# Delete border, ready to be reused. Save_perim is so single point borders don't add to score
func reset(save_perim: bool = true) -> void:
	line.clear_points()
	history.clear() # Just in case
	if save_perim:
		border_score += perimeter
		border_score += cast_score # Add and reset cast score. Inside save_perim so single points won't save cast score
		cast_score = 0
	perimeter = 0
	main_scene.update_border_display()

# Clear border and score
func reset_hard() -> void:
	border_score = 0
	cast_score = 0
	reset(false) # Don't add to score