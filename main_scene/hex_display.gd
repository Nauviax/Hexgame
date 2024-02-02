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

@export var replay_controls: Control # Should be shown while in replay mode

@export var replay_button: Button # Should be HIDDEN while in replay mode, as it enables it.

@export var replay_timeline_label: RichTextLabel

# Replay mode. Shows replay controls and disables player control.
# Manual casting will disable this mode.
var replay_mode: bool = false

# On ready, hide replay controls
func _ready():
	replay_timeline_label.clear() # Still shown technically, but empty
	replay_controls.hide()

# Handle Toggle Grid button
# Show/hide grid, rename button text, and set player control
func _on_toggle_grid_pressed():
	if grid_control.visible: # Hide grid, enable player control
		Globals.player_control = not replay_mode # True ONLY if not in replay mode
		toggle_grid_button.text = "Show Grid >"
		grid_control.hide()
		grid_control.set_process(false)
	else: # Show grid, disable player control
		Globals.player_control = false
		toggle_grid_button.text = "Hide Grid <"
		grid_control.show()
		grid_control.set_process(true)

# Update border size counter
func update_border_label(prev, current, cast):
	var cast_str = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score:\n" + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

# Update all labels related to hexecutor
func update_all_hexy():
	var hexecutor = main_scene.hexecutor
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
func _on_meta_hover_started(meta:Variant):
	pattern_info.display(meta)

func _on_meta_hover_started_low(meta:Variant):
	pattern_info.display(meta, true) # Display above mouse rather than below
	
func _on_meta_hover_ended(_meta):
	pattern_info.stop_display()

# Handle replay and replay controls

var replay_patterns: Array = []
var replay_index: int = 0 # Current pattern

func begin_replay():
	replay_patterns = main_scene.hexecutor.replay_list
	if replay_patterns.size() == 0:
		return # No replay to begin
	replay_mode = true
	Globals.player_control = false
	main_scene.reload_current_level(false) # Reload level, same state, keep border score
	replay_controls.show()
	replay_button.hide()
	replay_index = 0
	update_replay_timeline_label()
	# Get seed then request main_scene to regenerate level with it. (later)

func end_replay():
	replay_mode = false
	Globals.player_control = not grid_control.visible # Set player control based on grid visibility	
	replay_controls.hide()
	replay_button.show()
	replay_patterns = []
	replay_timeline_label.clear() # Still shown technically, but empty
	# Stay on the new regenerated level.

func update_replay_timeline_label():
	replay_timeline_label.clear() # Clear text
	for ii in range(replay_index - 2, replay_index + 4): # 6 total, 3rd drawn (If all 6 drawn) is bold 
		if ii < 0 or ii >= replay_patterns.size():
			continue # Skip if out of bounds
		var pattern = replay_patterns[ii]
		if pattern == null:
			pattern = "ClearGrid"
		var text = ""
		text += "[b]" + str(pattern) + "[/b]" if ii == replay_index else str(pattern) # Bold if pattern is next step (3rd drawn)
		if ii + 1 < replay_patterns.size():
			text += " ->" # Draw if next pattern exists
		replay_timeline_label.append_text(text) # Append
	if replay_index >= replay_patterns.size():
		replay_timeline_label.append_text("   <finished>") # Show if no more patterns to execute

func _on_begin_replay_button_pressed():
	begin_replay()

func _on_cont_here_pressed():
	end_replay()

func _on_step_pressed():
	if replay_index >= replay_patterns.size():
		return # No more patterns to execute
	var next = replay_patterns[replay_index]
	if next == null:
		main_scene.hexecutor.reset() # Clear grid on null
		update_clear_hexy() # Update stack display
	else:
		main_scene.hexecutor.execute_pattern(next) # Execute next pattern
	replay_index += 1
	update_replay_timeline_label()
