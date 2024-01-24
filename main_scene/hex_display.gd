extends Control

@onready var main_scene = get_parent()

@export var stack_path: NodePath # Set in Inspector
@onready var stack_label: RichTextLabel = get_node(stack_path)

@export var raven_path: NodePath 
@onready var raven_label = get_node(raven_path)

@export var reveal_path: NodePath
@onready var reveal_label = get_node(reveal_path)

@export var sb_path: NodePath
@onready var sb_label = get_node(sb_path)

@export var border_path: NodePath
@onready var border_label = get_node(border_path)

@export var level_desc_path: NodePath
@onready var level_desc_label = get_node(level_desc_path)

@export var validate_button_path: NodePath
@onready var validate_button = get_node(validate_button_path) # For changing color

@export var pattern_info_path: NodePath
@onready var pattern_info = get_node(pattern_info_path)

# Update border size counter
func update_border_label(prev, current, cast):
	var cast_str = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score: " + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

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
	var stack_size = stack.size()
	for ii in range(stack_size):
		stack_label.append_text(str(stack[stack_size - ii - 1]) + "\n")

# Ravenmind label
func update_ravenmind_label(ravenmind):
	if ravenmind == null:
		raven_label.text = ""
	else:
		raven_label.text = "Ravenmind: " + str(ravenmind)

# Reveal label
func update_reveal_label(reveal):
	if reveal == null:
		reveal_label.text = ""
	else:
		reveal_label.text = "Revealed: " + str(reveal)

# Spellbook label
func update_sb_label(player):
	var text = "- Spellbook -\n"
	for ii in range(player.sb.size()):
		if ii == player.sb_sel:
			text += "-> "
		else:
			text += "   "
		var iota = player.sb[ii]
		text += str(ii) + ": " + str(iota if iota != null else "") + "\n"
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

func _on_pattern_on_grid_hover(pog: Pattern_Ongrid): # Not yet implemented
	pattern_info.display(pog.pattern.p_code)

# Spellbook + Ravenmind also (Combine these maybe?)

# ALL rich text labels link to this function, as it's the same functionality for all of them
func _on_meta_hover_ended(_meta):
	pattern_info.stop_display()