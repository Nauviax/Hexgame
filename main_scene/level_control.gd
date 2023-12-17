extends CenterContainer

# Handles toggling player control
func _on_level_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		# L_click to toggle player control
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == true:
			Globals.player_control = !Globals.player_control

# Ensures that the Area2D is always the same size as the control (Should just run once. _ready() gives 0,0)
func _on_resized():
	$Level_Area2D/Area2D/CollisionShape2D.shape.size = self.size
