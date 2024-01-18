extends SubViewportContainer

# Handles toggling player control
func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		# L_click to toggle player control
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() == true:
			Globals.player_control = !Globals.player_control
