extends Node2D
class_name Pattern_On_Grid
# This class is used to display a pattern on the grid, and later(!!!) enable the player to interact with it.

# Line2D object that will display the pattern.
var grid_line2d: Line2D

# Ordered array of grid point objects that make up this pattern. First point is considered "origin".
var grid_points: Array = []

# Pattern object that this represents.
var pattern: Pattern = null

# Line2D to be used to show the pattern. Gradient should be updated later, as by default it's just black.
static var line_scene: PackedScene = preload("res://resources/shaders/cast_line/cast_line.tscn")

# Pattern on grid constructor. Takes the list of points that make up the pattern, and the relevant pattern object.
func _init(grid_points: Array, pattern: Pattern) -> void:
	self.grid_points = grid_points
	self.pattern = pattern

	# Create and prepare Line2D
	grid_line2d = line_scene.instantiate()
	add_child(grid_line2d)
	grid_line2d.prep_line() # Creates material duplicate
	# grid_line2d.material.set_shader_parameter("gradient_texture", line_gradient) # Unrequired, a default is already set.

	# Set the points of the line to the grid points.
	for point: Grid_Point in grid_points:
		grid_line2d.add_point(point.position)
		point.state = Grid_Point.State.TAKEN

	# Update shader segments
	grid_line2d.material.set_shader_parameter("segments", grid_line2d.get_point_count() - 1.0)

	# Tell pattern object where the line has been drawn.
	self.pattern.grid_location = Vector2i(grid_points[0].x_id, grid_points[0].y_id)

# Remove the pattern from the grid, freeing up all points and removing the line graphic.
func remove() -> void:
	# Free up all points.
	for point: Grid_Point in grid_points:
		point.state = Grid_Point.State.FREE
	grid_points.clear()
	# Remove line graphic.
	grid_line2d.queue_free()
	grid_line2d = null
	pattern = null
	# Remove this node.
	queue_free()

