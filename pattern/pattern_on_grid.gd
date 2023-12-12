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

	# Create pattern object.
	pattern = Pattern.new(points)

# Remove pattern from grid, freeing up all points and removing line graphic.
func remove():
	# Free up all points.
	for pnt in points:
		pnt.in_use = false
	points.clear()
	# Remove line graphic.
	line.queue_free()