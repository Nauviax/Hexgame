extends Control
class_name Hex_Display

# Logic for UI buttons and text display.
# Contains level replay logic and controls.

@onready var main_scene: Main_Scene = get_parent()

@export var toggle_grid_button: Button # Text control

@export var grid_control: Control

@export var stack_label: RichTextLabel # Set in Inspector

@export var spellbook_ui: PanelContainer # UI element that handles spellbook display, along with ravenmind, sentinel, and revealed iota data.

@export var border_label: Label

@export var level_controls: Control # For hiding/showing level controls, normally when a level isn't solvable.

@export var validation_result: Label # For announcing validation results

@export var hexbook_holder: Control

@export var replay_controls: Control # Should be shown while in replay mode

@export var preplay_controls: Control # Should be HIDDEN while in replay mode, as it enables it.

@export var preplay_begin_replay_button: Button # Hidden when level isn't solvable

@export var replay_timeline_label: RichTextLabel

@export var popup_holder: Control # All popups should be children of this

# As a general note: Spaces are added before \n to avoid weird issue with hover hitbox for meta-text extending the full width of the control.
# !!! This may be solved with the new fancy UI stuff. Look around to see if it's still an issue later !!!

# Replay mode. Shows replay controls and disables player control.
# Manual casting will disable this mode.
var replay_mode: bool = false

# Reference to the current popup. Should be reset after locking in place.
@onready var cur_popup: Hex_Popup = Hex_Popup.make_new(popup_holder)

# On ready, hide replay controls
func _ready() -> void:
	replay_timeline_label.clear() # Still shown technically, but empty
	replay_controls.hide()
	validation_result.text = "" # Clear validation label

# Handle Toggle Grid button
func _on_toggle_grid_pressed() -> void:
	toggle_grid()

# Show/hide grid, rename button text, and set player control
func toggle_grid() -> void:
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
func _on_hexbook_pressed() -> void:
	hexbook_holder.visible = not hexbook_holder.visible

# Update border size counter
func update_border_label(prev: int, current: int, cast: int) -> void:
	var cast_str: String = (" + " + str(cast)) if cast != 0 else ""
	border_label.text = "Border score:\n" + str(prev) + " + " + str(current) + cast_str + " = " + str(prev + current + cast)

# Update stack, spellbook and misc spellbook items to both show dead entity references and clear sentinel/revealed iota.
func handle_update_all_iotas(hexecutor: Hexecutor) -> void:
	update_stack(hexecutor.stack)
	var player: Player = hexecutor.caster.node
	var revealed_iota: Variant = hexecutor.level_base.revealed_iota if hexecutor.level_base else null # level_base can be null if not in a level # !!! CHECK IF THIS IS NEEDED
	update_sb_all(player.sb, player.sb_sel, player.ravenmind, player.sentinel_pos, revealed_iota)

# Update all items related to clearing the grid, and clear error history
func handle_clear_grid() -> void:
	update_stack([])
	update_sb_item(9, "", true) # Silent update so ravenmind doesn't pull focus.

# Stack label
func update_stack(stack: Array) -> void:
	stack_label.clear()
	var text: String = ""
	var stack_size: int = stack.size()
	for ii in range(stack_size):
		var iota: Variant = stack[stack_size - ii - 1]
		text += iota_to_string(iota) + " \n"
	stack_label.append_text(text)

# Turns an iota into a display string with metatext for popups. For use in spellbook_ui and stack mainly.
# Will call itself recursively if the iota is an array. Arrays are shortened, but nested lists are not.
# !!! Investigate weird hover hitbox issue. Solution is to put a space as last character, but don't use yet unless necessary.
func iota_to_string(iota: Variant, inside_list: bool = false) -> String:
	if iota == null:
		return "null" if inside_list else "" # Don't show nulls in spellbook, but do show in lists.
	elif iota is Pattern:
		return iota.name_short_meta if inside_list else iota.name_display_meta # Shorten if inside list, Full length if not.
	elif iota is Array:
		var text: String = "["
		var max_length: int = 0 # How many items to display before shortening
		if inside_list:
			max_length = iota.size() # Show all items if inside a list.
		else: # Calculate a custom max_length to shorten list if needed.
			var length_score: int = 0 # An estimate of how long the list will be, to determine if it should be shortened.
			for ii: Variant in iota:
				if ii is Pattern:
					length_score += ii.name_short.length() + 2 # Length of short name, plus ", "
				elif ii is Array:
					length_score += 8 # Length of "(list), "
				elif ii is Bad_Iota:
					length_score += 12 # 10 long, plus ", "
				else:
					length_score += str(ii).length() + 2 # Float, Vector2, Entity even. +2 For ", " between items
				if length_score > 40: # If the list is too long, shorten it.
					break
				max_length += 1 # Increment max_length
		# Generate text for each item in the list, shortening if needed.
		for ii in range(max_length):
			if (not inside_list) and (iota[ii] is Array): # Do NOT show a whole ass list while trying to keep everything short.
				var meta: String = iota_to_string(iota[ii], true).replace("[", "BBCODELEFT").replace("]", "BBCODERIGHT")
				text += "[url=L" + meta + "](list)[/url]" # Append a shortened list instead.
			else:
				text += iota_to_string(iota[ii], true) # Don't shorten nested lists (!!! But look into what happens if we do, once all this works!)
			if ii < iota.size() - 1:
				text += ", "
		if (not inside_list) and (iota.size() > max_length): # Add ellipsis with link to full list if list is too long.
			var meta: String = iota_to_string(iota, true).replace("[", "BBCODELEFT").replace("]", "BBCODERIGHT") # Replace brackets to avoid issues with meta-text
			text += "[url=L" + meta + "]. . . [/url]" # Spaced out to make hitbox larger mainly.
		text += "]"
		return text
	else: # Floats, Vector2, Entity, anything else I don't have special rules for.
		return str(iota)

# Refresh whole spellbook ui. Used when all items may have changed, like when loading into a new level.
func update_sb_all(sb: Array, sb_sel: int, raven: Variant, sentinel: Variant, revealed: Variant) -> void:
	for ii in sb.size(): # sb should always be 9 long
		spellbook_ui.update_spellbook_item(ii, iota_to_string(sb[ii]), false, false)
	spellbook_ui.update_spellbook_item(9, iota_to_string(raven), false, false)
	spellbook_ui.update_spellbook_item(10, iota_to_string(sentinel), false, false)
	spellbook_ui.update_spellbook_item(11, iota_to_string(revealed), false, false) # Update spellbook on last item.
	spellbook_ui.update_selected_iota(sb_sel) # Also causes spellbook to update display, and move to selected page.

# Update the selected iota index, and move to the relevant tab.
func update_sb_selection(index: int) -> void:
	spellbook_ui.update_selected_iota(index)

# Update items related to spellbook_ui.
# General iotas use index values 0-8, and misc iotas are 9-11 for ravenmind, sentinel, and revealed iota.
func update_sb_item(index: int, iota: Variant, silent: bool = false) -> void:
	spellbook_ui.update_spellbook_item(index, iota_to_string(iota), true, silent)

# Level description label (Called directly by main_scene)
func set_puzzle_tool_visibility(is_puzzle: bool) -> void:
	# Reset validatation label (!!! This probably will be changed soon)
	validation_result.text = "Level not valid yet." if is_puzzle else ""
	# Hide/show controls based on if level is intended to be solved
	level_controls.visible = is_puzzle
	preplay_begin_replay_button.visible = is_puzzle

# Seperate call so hexecutor can call this code via main_scene
func set_validate_result(validated: bool) -> void:
	validation_result.text = "Validated!\nNow try ExValidate!" if validated else "Level not valid yet."

func _on_extra_validate_pressed() -> void: # The repeating one
	var validated: bool = main_scene.validate_level() # Ensure level is solved before attempting to ExValidate
	if validated:
		var ex_result: Array = main_scene.extra_validate_level()
		if ex_result.size() == 2: # Returns either results or empty Array
			validation_result.text = "You Win!\nHex size: " + str(ex_result[0]) + "\nBorder size: " + str(ex_result[1])
		else:
			validation_result.text = "Failed, replay for bad seed shown."
	else:
		validation_result.text = "Can't ExValidate yet, level not valid."

# Handle meta-text and other pattern hovers
func _on_meta_hover_started(meta: Variant) -> void:
	cur_popup.display(meta)

func _on_meta_hover_started_low(meta: Variant) -> void:
	cur_popup.display(meta, true) # Display above mouse rather than below

func _on_meta_clicked(_meta: Variant) -> void:
	if not cur_popup.visible:
		return # Popup hasn't been used yet.
	cur_popup.lock() # Stop info from following mouse or disappearing
	cur_popup = Hex_Popup.make_new(popup_holder) # Get new popup

func _on_meta_hover_ended(_meta: Variant) -> void:
	cur_popup.stop_display()

# Handle replay and replay controls

var replay_patterns: Array = []
var replay_index: int = 0 # Current pattern

func begin_replay(patterns: Array = []) -> void: # Optionally specify patterns to replay with
	replay_patterns = main_scene.hexecutor.replay_list if patterns == [] else patterns # Get replay patterns
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

func end_replay() -> void:
	replay_mode = false
	Globals.player_control = not grid_control.visible # Set player control based on grid visibility	
	replay_controls.hide()
	preplay_controls.show()
	replay_patterns = []
	replay_timeline_label.clear() # Still shown technically, but empty
	# Stay on the new regenerated level.

func update_replay_timeline_label() -> void:
	replay_timeline_label.clear() # Clear text
	for ii in range(replay_index - 2, replay_index + 4): # 6 total, 3rd drawn (If all 6 drawn) is bold 
		if ii < 0 or ii >= replay_patterns.size():
			continue # Skip if out of bounds
		var pattern: Pattern = replay_patterns[ii] # Pattern can be null, for ClearGrid.
		var text: String = ""
		if pattern == null:
			text += "[b]ClearGrid[/b]" if ii == replay_index else "ClearGrid" # Bold if clear is next step (3rd drawn)
		else:
			text += "[b]" + str(pattern) + "[/b]" if ii == replay_index else str(pattern) # Bold if pattern is next step (3rd drawn)
		if ii + 1 < replay_patterns.size():
			text += " -> " # Draw if next pattern exists
		replay_timeline_label.append_text(text) # Append
	if replay_index >= replay_patterns.size():
		replay_timeline_label.append_text("   <finished>") # Show if no more patterns to execute

func _on_begin_replay_button_pressed() -> void:
	begin_replay()

func _on_reset_level_pressed() -> void:
	main_scene.reload_current_level(true, false) # Hard reset, new seed

func _on_cont_here_pressed() -> void:
	end_replay()

func _on_step_pressed() -> void:
	if playing_replay:
		playing_replay = false # Stop playing replay if it's on, rather than stepping
	else:
		step_replay()

var playing_replay: bool = false
func _on_play_pause_pressed() -> void:
	playing_replay = not playing_replay # Toggle playing replay, which will also toggle it off if pressed a second time
	while playing_replay and replay_index < replay_patterns.size():
		step_replay()
		await get_tree().create_timer(0.25).timeout # Wait 0.25 seconds between each step
	if playing_replay:
		end_replay()
		playing_replay = false

func step_replay() -> void:
	if replay_index >= replay_patterns.size():
		return # No more patterns to execute
	var next: Pattern = replay_patterns[replay_index]
	if next == null:
		SoundManager.play_fail() # Sound effect for clear grid
		main_scene.hexecutor.reset() # Clear grid on null
		handle_clear_grid() # Update stack display
	else:
		main_scene.hexecutor.execute_with_effects(next) # Execute pattern
	replay_index += 1
	update_replay_timeline_label()

# Quickly close all locked popups. cur_popup is not included, as it would not be locked.
func _on_close_popups_pressed() -> void:
	var popups: Array = popup_holder.get_children()
	for popup: Hex_Popup in popups:
		popup.close_if_locked()
