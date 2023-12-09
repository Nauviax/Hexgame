extends Node2D

@onready var mouse_area = $MouseArea # Area2D
@onready var polygon = $Polygon2D # Polygon2D
@onready var init_scale = polygon.scale.x
@onready var parent_grid = get_parent()

var x_id = 0
var y_id = 0

# in_use means the point is part of a previous pattern
var in_use = false #:
	# set(val):
	# 	in_use = val
	# 	if in_use:
	# 		polygon.color = Color(1, 0, 0, 1) # Red when in use
	# 	else:
	# 		polygon.color = Color(1, 1, 1, 1) # White when not in use

# Had issues when not using this method. This works anyway.
func set_id(x, y):
	x_id = x
	y_id = y

# Call parent when mouse entered while clicking
func _on_mouse_area_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		parent_grid.on_point(self)

# Call parent when mouse starts clicking on me
func _on_mouse_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		parent_grid.on_point(self)

# Animate based on mouse distance
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var dist = global_position.distance_to(mouse_pos)
	var scale_factor = init_scale * exp(-dist / 40) # Adjust the div value as needed
	polygon.scale = Vector2(scale_factor, scale_factor)
