class_name Hexecutor
extends Resource # So one off instances can be removed automatically.

# Reference to main scene
# Can be left null, but will not update the stack display. (For when a hexecutor doesn't belong to a grid/display)
var main_scene = null

# Various gradients for pattern lines, to be set depending on state.
# Static as they can be shared between all instances of this class.
static var normal_gradient = preload("res://resources/gradients/normal.tres")
static var fail_gradient = preload("res://resources/gradients/fail.tres")
static var meta_gradient = preload("res://resources/gradients/meta.tres")

# The stack (Very important)
var stack = []

# A reference to the level_info the caster is a part of.
# Used to get entities and other level data for certian patterns.
var level_info = null

# The entity casting this hex (Normally the player)
# Should be an entity from level_info, but not *necessarily* the player.
var caster = null

# Consideration Mode
# If true, the next executed pattern will be saved to the stack as a pattern. (Metalist or just on it's own)
# This takes priority over introspection mode, though still appends to Metalist. It can be used to add intro/retrospection to a list.
# Adding consideration to the list requires two considerations in a row.
var consideration_mode = false

# Introspection Mode
# If > 0, executed patterns are instead saved to the Pattern_Metalist at the top of the stack.
# If the top of the stack is not a Pattern_Metalist, throw a Godot error (Not bad_iota)
# Incremented/Decremented via Introspection and Retrospection respectively.
var introspection_depth = 0

# Execution depth
# Used to halt a meta-pattern if it is too deep.
# Incremented/Decremented by the meta-patterns themselves. Just read by Hexecutor to halt early.
# Current max depth is 128.
var execution_depth = 0

# Charon Mode
# If true, exit the current meta-pattern. Meta-pattern should set this to false on exit.
# If not in a meta-pattern, simply end this hex (Clear grid and stack etc)
var charon_mode = false

# Constructor
# If not given a main_scene, will not update the stack display.
func _init(level_info, caster, main_scene = null):
	self.level_info = level_info
	self.caster = caster
	self.main_scene = main_scene
		
# Tries to validate the pattern, colors it, then executes it (With sounds)
func new_pattern(pattern_og: Pattern_Ongrid): # Defined type to avoid future mistakes
	var is_meta = consideration_mode or introspection_depth > 0 # For coloring patterns
	var success = execute_pattern(pattern_og.pattern)
	# Splash of color and sound
	if is_meta:
		SoundManager.play_normal()
		if pattern_og.pattern.name == "Retrospection" and introspection_depth == 0: # Special case for last retrospection
			pattern_og.line.gradient = normal_gradient
		else:
			pattern_og.line.gradient = meta_gradient
	elif success: # Pattern is valid and executed successfully
		SoundManager.play_normal()
		pattern_og.line.gradient = normal_gradient
	else: # Pattern is invalid or failed to execute
		SoundManager.play_fail()
		pattern_og.line.gradient = fail_gradient

# Executes a given pattern (Of note: NOT a Pattern_Ongrid)
func execute_pattern(pattern: Pattern, update_on_success = true):
	var return_string = ""
	if execution_depth > 128: # Max depth
		return_string = "Error: Execution depth too high (Max 128)"
	else: # Execute normally
		if consideration_mode: # Single meta-pattern mode, see var declaration.
			if stack.size() > 0 and stack[-1] is Pattern_Metalist:
				stack[-1].patterns.push_back(pattern)
			else:
				stack.push_back(pattern) # Append to stack with no list
			consideration_mode = false
		elif introspection_depth > 0 and pattern.name != "Consideration": # Multi meta-pattern mode, see var declaration.
			if stack.size() > 0 and stack[-1] is Pattern_Metalist:
				return_string = stack[-1].add_pattern(self, pattern)
			else:
				printerr("ERROR: Introspection mode enabled, but top of stack is not a Pattern_Metalist!")
				return
		else: # Default mode, just execute the pattern
			return_string = pattern.execute(self)

	# If AFTER meta-execution, charon_mode is true, end hex.
	if charon_mode and execution_depth == 0:
		charon_mode = false
		main_scene.clear() # Wipe grid and stack
		return true # Return early

	# Special case for patterns that don't want to update the display on return.
	# Currently used when meta-executed patterns fail, to prevent error spam. Please don't return null elsewhere.
	# (I want to change my error system, so this is somewhat temporary (!!!))
	if return_string == null:
		return false

	var success = return_string.left(5) != "Error" # Check if return string contains "Error"
	# Can choose to only update display on fail. Good for meta-patterns which run many patterns.
	# Additionally, if main_scene is null, will not run updates. (Useful for oneoff hexecutor instances)
	if (update_on_success or not success) and (main_scene != null):
		main_scene.update_hex_disp(return_string) # Update stack display
		scan_stack() # Debugging, comment out when not needed anymore (!!!)
	return success

# Debugging function, should not run in final product.
# Ensures no ints enter the stack. Will warn in console and throw if it does.
# Also ensures no duplicate array references are in the stack.
func scan_stack():
	var array_list = []
	for item in stack:
		if item is int:
			printerr("WARNING: Int found in stack!")
		if item is Array:
			for arr in array_list:
				if is_same(arr, item): # By reference, not the same as ==
					printerr("WARNING: Duplicate array reference found in stack!")
			array_list.append(item)

# Reset hexecutor func. Can also be called to reset hexecutor when not attached to a grid/display.
# Does not touch execution_depth or charon_mode, as they should be reset by meta-patterns automatically.
func reset(keep_raven = false):
	stack = []
	if not keep_raven: # Thoths keeps ravenmind intact.
		caster.ravenmind = null
	consideration_mode = false
	introspection_depth = 0