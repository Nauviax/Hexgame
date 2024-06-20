extends Control

# Logic for UI buttons and text display.
# Contains level replay logic and controls.

@onready var main_scene = get_parent()

@export var toggle_grid_button: Button # Text control

@export var grid_control: Control

@export var stack_label: RichTextLabel # Set in Inspector

@export var spellbook_ui: PanelContainer # UI element that handles spellbook display, along with ravenmind, sentinel, and revealed iota data.

@export var border_label: Label

@export var level_controls: Control # For hiding/showing level controls, normally when a level isn't solvable.

@export var validate_button: Button # For changing color

@export var validate_label: Label # For announcing validation results

@export var hexbook_holder: Control

@export var replay_controls: Control # Should be shown while in replay mode

@export var preplay_controls: Control # Should be HIDDEN while in replay mode, as it enables it.

@export var preplay_begin_replay_button: Button # Hidden when level isn't solvable

@export var replay_timeline_label: RichTextLabel

@export var popup_holder: Control # All popups should be children of this

# As a general note: Spaces are added before \n to avoid weird issue with hover hitbox for meta-text extending the full width of the control.

# Replay mode. Shows replay controls and disables player control.
# Manual casting will disable this mode.
var replay_mode: bool = false

# Reference to the current popup. Should be reset after locking in place.
@onready var popup: Hex_Popup = Hex_Popup.make_new(popup_holder)

# On ready, hide replay controls
func _ready():
	replay_timeline_label.clear() # Still shown technically, but empty
	replay_controls.hide()
	validate_label.text = "" # Clear validation label

# Handle Toggle Grid button
func _on_toggle_grid_pressed():
	toggle_grid()

# Show/hide grid, rename button text, and set player control
func toggle_grid():
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

# Handle Hexbook button
func _on_hexbook_pressed():
	hexbook_holder.visible = not hexbook_holder.visible

# Update border size counter
func update_border_label(prev, current, cast):
	var cast_str = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score:\n" + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

# Update stack, spellbook and misc spellbook items to both show dead entity references and clear sentinel/revealed iota.
func handle_update_all_iotas(hexecutor: Hexecutor):
	update_stack(hexecutor.stack)
	var player = hexecutor.caster.node
	var revealed_iota = hexecutor.level_base.revealed_iota if hexecutor.level_base else null # level_base can be null if not in a level # !!! CHECK IF THIS IS NEEDED
	update_sb_all(player.sb, player.sb_sel, player.ravenmind, player.sentinel_pos, revealed_iota)

# Update all items related to clearing the grid, and clear error history
func handle_clear_grid():
	update_stack([])
	update_sb_item(9, "", true) # Silent update so ravenmind doesn't pull focus.

# Stack label
func update_stack(stack: Array):
	stack_label.clear()
	var text = ""
	var stack_size = stack.size()
	for ii in range(stack_size):
		var iota = stack[stack_size - ii - 1]
		if iota is Pattern:
			text += iota.get_meta_string() + " \n"
		else:
			text += str(iota) + " \n"
	stack_label.append_text(text)

# Ravenmind label
# func update_ravenmind_label(ravenmind):
# 	if ravenmind == null:
# 		raven_label.text = ""
# 	elif ravenmind is Pattern:
# 		raven_label.text = "Ravenmind:\n" + ravenmind.get_meta_string() + " \n" # Avoid issue with hover hitbox
# 	else:
# 		raven_label.text = "Ravenmind:\n" + str(ravenmind) + " \n"

# Reveal label
# func update_reveal_label(reveal):
# 	if reveal == null:
# 		reveal_label.text = ""
# 	elif reveal is Pattern:
# 		reveal_label.text = "Revealed:\n" + reveal.get_meta_string() + " \n"
# 	else:
# 		reveal_label.text = "Revealed:\n" + str(reveal) + " \n"

# Spellbook label
# func update_sb_label(player):
# 	var text = "- Spellbook -\n"
# 	for ii in range(player.sb.size()):
# 		if ii == player.sb_sel:
# 			text += "-> " + str(ii) + ": "
# 		else:
# 			text += "   " + str(ii) + ": "
# 		var iota = player.sb[ii]
# 		if iota == null:
# 			text += "\n"
# 		elif iota is Pattern:
# 			text += iota.get_meta_string() + " \n" # Again, space to avoid issue with hover hitbox
# 		else:
# 			text += str(iota) + " \n"
# 	sb_label.text = text

# Refresh whole spellbook ui. Used when all items may have changed, like when loading into a new level.
# !!! DON'T USE str() USE SOME NEW FUNC TO BE DEFINED SOON (null == "")
func update_sb_all(sb:Array, sb_sel:int, raven, sentinel, revealed):
	for ii in sb.size(): # sb should always be 9 long
		spellbook_ui.update_spellbook_item(ii, str(sb[ii]), false, false)
	spellbook_ui.update_spellbook_item(9, str(raven), false, false)
	spellbook_ui.update_spellbook_item(10, str(sentinel), false, false)
	spellbook_ui.update_spellbook_item(11, str(revealed), false, false) # Update spellbook on last item.
	spellbook_ui.update_selected_iota(sb_sel) # Also causes spellbook to update display, and move to selected page.

# Update the selected iota index, and move to the relevant tab.
func update_sb_selection(index:int):
	spellbook_ui.update_selected_iota(index)

# Update items related to spellbook_ui.
# General iotas use index values 0-8, and misc iotas are 9-11 for ravenmind, sentinel, and revealed iota.
func update_sb_item(index:int, iota, silent:bool = false):
	spellbook_ui.update_spellbook_item(index, str(iota), true, silent)

# Level description label (Called directly by main_scene)
func set_puzzle_tool_visibility(is_puzzle: bool):
	# Reset validate button and label state (!!! This probably will be changed soon)
	validate_label.text = ""
	validate_button.modulate = Color(1, 1, 1)
	# Hide/show controls based on if level is intended to be solved
	level_controls.visible = is_puzzle
	preplay_begin_replay_button.visible = is_puzzle

# Handle UI buttons
func _on_level_validate_pressed():
	main_scene.validate_level() # Will call set_validate_result in this script

# Seperate call so hexecutor can call this code via main_scene
func set_validate_result(validated: bool):
	if validated:
		validate_button.modulate = Color(0, 1, 0) 
		validate_label.text = "Validated!\nNow try ExValidate!"
	else:
		validate_button.modulate = Color(1, 0, 0)
		validate_label.text = "Level not valid yet."

func _on_extra_validate_pressed(): # The repeating one
	var validated = main_scene.validate_level()
	if validated:
		var ex_result = main_scene.extra_validate_level()
		if ex_result.size() == 2:
			validate_button.modulate = Color(0, 1, 0)
			validate_label.text = "You Win!\nHex size: " + str(ex_result[0]) + "\nBorder size: " + str(ex_result[1])
		else:
			validate_button.modulate = Color(1, 0, 0)
			validate_label.text = "Failed, replay for bad seed shown."
	else:
		validate_button.modulate = Color(1, 0, 0)
		validate_label.text = "Level isn't even valid yet."

# Handle meta-text and other pattern hovers
func _on_meta_hover_started(meta:Variant):
	popup.display(meta)

func _on_meta_hover_started_low(meta:Variant):
	popup.display(meta, true) # Display above mouse rather than below

func _on_meta_clicked(_meta:Variant):
	if not popup.visible:
		return # Popup hasn't been used yet.
	popup.lock() # Stop info from following mouse or disappearing
	popup = Hex_Popup.make_new(popup_holder) # Get new popup

func _on_meta_hover_ended(_meta):
	popup.stop_display()

# Handle replay and replay controls

var replay_patterns: Array = []
var replay_index: int = 0 # Current pattern

func begin_replay(patterns = null): # Optionally specify patterns to replay with
	replay_patterns = main_scene.hexecutor.replay_list if patterns == null else patterns # Get replay patterns
	if replay_patterns.size() == 0:
		return # No replay to begin
	replay_mode = true
	Globals.player_control = false
	main_scene.reload_current_level(false) # Reload level, same state, keep border score
	replay_controls.show()
	preplay_controls.hide()
	replay_index = 0
	update_replay_timeline_label()
	# Get seed then request main_scene to regenerate level with it. (later)

func end_replay():
	replay_mode = false
	Globals.player_control = not grid_control.visible # Set player control based on grid visibility	
	replay_controls.hide()
	preplay_controls.show()
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

func _on_reset_level_pressed():
	main_scene.reload_current_level(true, false) # Hard reset, new seed

func _on_cont_here_pressed():
	end_replay()

func _on_step_pressed():
	if playing_replay:
		playing_replay = false # Stop playing replay if it's on, rather than stepping
	else:
		step_replay()

var playing_replay: bool = false
func _on_play_pause_pressed():
	playing_replay = not playing_replay # Toggle playing replay, which will also toggle it off if pressed a second time
	while playing_replay and replay_index < replay_patterns.size():
		step_replay()
		await get_tree().create_timer(0.25).timeout # Wait 0.25 seconds between each step
	if playing_replay:
		end_replay()
		playing_replay = false

func step_replay():
	if replay_index >= replay_patterns.size():
		return # No more patterns to execute
	var next = replay_patterns[replay_index]
	if next == null:
		main_scene.hexecutor.reset() # Clear grid on null
		handle_clear_grid() # Update stack display
	else:
		main_scene.hexecutor.execute_with_effects(next) # Execute pattern
	replay_index += 1
	update_replay_timeline_label()
