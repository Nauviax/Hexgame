extends Node2D
class_name Grid_Point

@onready var mouse_area: Area2D = $MouseArea
@onready var polygon: Polygon2D = $Polygon2D
@onready var init_scale: float = polygon.scale.x
@onready var parent_grid: Node2D = get_parent()

static var scale_max_distance: float = 400.0 # Distance at which points will show as 0 scale

var xy_id: Vector2i = Vector2i(0, 0)

# Various states this point can have. Affects is_free() and point's color.
enum State {
	FREE, 		# Point is not in use.
	DRAWING,	# Being used to draw a new pattern.
	TAKEN,		# Has been used to draw a pattern, can no longer be used.
	RESERVED,	# Belongs to a pattern, but said pattern is being moved. Effectively a free point. (Should have priority over HOVERED)
	HOVERED,	# A pattern is being held above this point. Effectively a free point, unless pattern is placed here.
	# !!! Hovered AND reserved state may be useful too
}

# State var for this point. Changing state will automatically update the point's color
var state: State = State.FREE:
	set(val):
		state = val
		match state:
			State.FREE: polygon.color = Color(1, 1, 1, 1) # White
			State.DRAWING: polygon.color = Color(1, 1, 0, 1) # Yellow
			State.TAKEN: polygon.color = Color(1, 0, 0, 1) # Red
			State.RESERVED: polygon.color = Color(1, 0.6, 0, 1) # Orange
			State.HOVERED: polygon.color = Color(1, 1, 0, 1) # Yellow
			_: pass # !!! TODO


# Returns true if this point is considered "taken"
# Currently this is false if point is anything other than TAKEN, but may change in future.
func is_in_use() -> bool:
	return state == State.TAKEN

# Call parent when mouse entered, different depending if clicking/dragging (Only if grid has control)
func _on_mouse_area_mouse_entered() -> void:
	if Globals.player_control:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		parent_grid.on_point_left(self)
	else:
		parent_grid.on_point_hover(self)

# Call parent when mouse starts clicking on this point (Only if grid has control)
func _on_mouse_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Globals.player_control:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			parent_grid.on_point_left(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			parent_grid.on_point_right(self)

# Animate based on mouse distance
func _process(_delta: float) -> void:
	if Globals.player_control:
		# polygon.scale = Vector2.ZERO Not needed currently as grid is hidden while this is true. Left commented jic
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dist: float = global_position.distance_to(mouse_pos)
	# var scale_factor: float = init_scale * exp(-dist / 150) # Old scale factor logic. Possibly cooler, but probably slower.
	var scale_factor: float = max(0, init_scale * (1 - dist / scale_max_distance))
	polygon.scale = Vector2(scale_factor, scale_factor)
