extends Control

@onready var main_scene = get_parent()

@export var toggle_grid_button: Button

@export var grid_control: Control

@export var stack_label: RichTextLabel # Set in Inspector

@export var raven_label: RichTextLabel

@export var reveal_label: RichTextLabel

@export var sb_label: RichTextLabel

@export var border_label: Label

@export var level_desc_label: Label

@export var validate_button: Button # For changing color

@export var pattern_info: PanelContainer

# Handle Toggle Grid button
# Show/hide grid, rename button text, and set player control
func _on_toggle_grid_pressed():
	if Globals.player_control: # Show grid, disable player control
		Globals.player_control = false
		toggle_grid_button.text = "Hide Grid <"
		grid_control.show()
		grid_control.set_process(true)
	else: # Hide grid, enable player control
		Globals.player_control = true
		toggle_grid_button.text = "Show Grid >"
		grid_control.hide()
		grid_control.set_process(false)

# Update border size counter
func update_border_label(prev, current, cast):
	var cast_str = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score:\n" + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

# Update all labels related to hexecutor
func update_all_hexy(hexecutor):
	update_stack(hexecutor.stack)
	update_ravenmind_label(hexecutor.caster.node.ravenmind)
	if hexecutor.level_base: # Can be null if not in a level
		update_reveal_label(hexecutor.level_base.revealed_iota)
	else:
		update_reveal_label(null) # Clear
	update_sb_label(hexecutor.caster.node)

# Update all labels related to clearing the grid, and clear error history
func update_clear_hexy():
	update_stack([])
	update_ravenmind_label(null)

# Stack label
func update_stack(stack):
	stack_label.clear()
	var text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		var iota = stack[stack_size - ii - 1]
		if iota is Pattern:
			text += iota.get_meta_string() + "\n"
		else:
			text += str(iota) + "\n"
	stack_label.append_text(text)

# Ravenmind label
func update_ravenmind_label(ravenmind):
	if ravenmind == null:
		raven_label.text = ""
	elif ravenmind is Pattern:
		raven_label.text = "Ravenmind:\n" + ravenmind.get_meta_string()
	else:
		raven_label.text = "Ravenmind:\n" + str(ravenmind)

# Reveal label
func update_reveal_label(reveal):
	if reveal == null:
		reveal_label.text = ""
	elif reveal is Pattern:
		reveal_label.text = "Revealed:\n" + reveal.get_meta_string()
	else:
		reveal_label.text = "Revealed:\n" + str(reveal)

# Spellbook label
func update_sb_label(player):
	var text = "- Spellbook -\n"
	for ii in range(player.sb.size()):
		if ii == player.sb_sel:
			text += "-> " + str(ii) + ": "
		else:
			text += "   " + str(ii) + ": "
		var iota = player.sb[ii]
		if iota == null:
			text += "\n"
		elif iota is Pattern:
			text += iota.get_meta_string() + "\n"
		else:
			text += str(iota) + "\n"
	sb_label.text = text

# Level description label (Called directly by main_scene)
func update_level_desc_label(text):
	level_desc_label.text = text
	# Reset validate button color
	validate_button.modulate = Color(1, 1, 1)

# Handle UI buttons
func _on_level_validate_pressed():
	var validated = main_scene.validate_level()
	print ("Valid level: " + str(validated))
	validate_button.modulate = Color(0, 1, 0) if validated else Color(1, 0, 0)

# Handle meta-text and other pattern hovers
func _on_stack_meta_hover_started(meta:Variant):
	if meta is String: # Either error message or pattern code
		pattern_info.display(meta)

func _on_spellbook_meta_hover_started(meta:Variant):
	if meta is String: # Same idea as above
		pattern_info.display(meta)

func _on_ravenmind_meta_hover_started(meta:Variant):
	if meta is String:
		pattern_info.display(meta)

func _on_reveal_meta_hover_started(meta:Variant):
	if meta is String:
		pattern_info.display(meta)

func _on_pattern_on_grid_hover(pog: Pattern_Ongrid): # Not yet implemented
	pattern_info.display(pog.pattern.p_code)

# ALL rich text labels link to this function, as it's the same functionality for all of them
func _on_meta_hover_ended(_meta):
	pattern_info.stop_display()