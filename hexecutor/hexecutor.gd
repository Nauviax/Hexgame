class_name Hexecutor
extends Resource # So one off instances can be removed automatically.

# Reference to main scene
var main_scene: Node2D

# True if this hexecutor should interact with the main scene directly.
# This includes updating the display, but patterns can still interact using this reference!
var is_main_hexecutor

# Various gradients for pattern lines, to be set depending on state.
# Static as they can be shared between all instances of this class.
static var normal_gradient = preload("res://resources/shaders/cast_line/gradient_textures/normal.tres")
static var fail_gradient = preload("res://resources/shaders/cast_line/gradient_textures/fail.tres")
static var meta_gradient = preload("res://resources/shaders/cast_line/gradient_textures/meta.tres")

# The stack (Very important)
var stack = []

# A reference to the level_base the caster is a part of.
# Used to get entities and other level data for certian patterns.
# If left null, pattern execution will fail. Can be intentionally left null to prevent execution.
var level_base = null

# The entity representing the player casting this hex. (Will cause issues if caster.node is not type player!)
var caster: Entity = null

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

# Scram Mode
# If true, the the hex will attempt to end. Similar to Charon Mode, but does NOT respect meta-patterns.
# Used for patterns that should not be followed by other patterns. (Enter and Exit for instance)
# Not reset by hexecutor, main_scene should reset this when it needs to use the hexecutor again.
var scram_mode = false

# Replay List
# Executed patterns append themselves to the replay list. These patterns can later be executed in order to replicate the original hex.
# Only saves top level patterns, when execution_depth == 0. (So Hermes would be saved, but not the patterns it executes.)
# Null in list represents a grid clear. Movements preformed by the player are NOT recorded, though currently the manual cast action IS saved. (It runs patterns directly)
# Should be (Inherently?) reset only on level reset, or when entering replay mode. List will effectively rebuild itself during any replay so manual casting can safely resume anytime.
var replay_list = []

# Constructor
# If not is_main_hexecutor, will not update the stack display.
func _init(level_base, caster, main_scene, is_main_hexecutor = true):
	self.level_base = level_base
	self.caster = caster
	self.main_scene = main_scene
	self.is_main_hexecutor = is_main_hexecutor
		
# Tries to validate the pattern, colors it, then executes it (With sounds)
func new_pattern(pattern_og: Pattern_Ongrid): # Defined type to avoid future mistakes
	var is_meta = consideration_mode or introspection_depth > 0 # For coloring patterns
	var success = execute_pattern(pattern_og.pattern)
	# Splash of color and sound
	if is_meta:
		SoundManager.play_normal() # No fancy thoth etc sounds while appending to a pattern list
		if pattern_og.pattern.name == "Retrospection" and introspection_depth == 0: # Special case for last retrospection
			Hexecutor.set_gradient(pattern_og, normal_gradient)
			caster.node.particle_cast(0)
		else:
			Hexecutor.set_gradient(pattern_og, meta_gradient)
			caster.node.particle_cast(2)
	elif success: # Pattern is valid and executed successfully
		if pattern_og.pattern.name == "Thoth's Gambit":
			SoundManager.play_thoth()
		elif pattern_og.pattern.name == "Hermes' Gambit":
			SoundManager.play_hermes()
		elif pattern_og.pattern.is_spell: # Spells are patterns that interact with the level in some way, including getting or reading from entities.
			SoundManager.play_spell()
		else:
			SoundManager.play_normal()
		Hexecutor.set_gradient(pattern_og, normal_gradient)
		caster.node.particle_cast(0)
	else: # Pattern is invalid or failed to execute
		SoundManager.play_fail()
		Hexecutor.set_gradient(pattern_og, fail_gradient)
		caster.node.particle_cast(1)
	# End replay mode if it was active
	main_scene.end_replay_mode()

# Quick way to set a pattern_og line to a gradient. Static.
static func set_gradient(pattern_og: Pattern_Ongrid, gradient):
	pattern_og.line.material.set_shader_parameter("gradient_texture", gradient)

# Executes a given pattern (Of note: NOT a Pattern_Ongrid)
func execute_pattern(pattern: Pattern, update_on_success = true):
	# If scram mode, end hex.
	if scram_mode:
		print("Scram mode active, ending hex.")
		return false # Return early (And "fail" via false, so meta-patterns don't continue)
	
	var success # Return value, true on successful pattern execution, false otherwise.
	if execution_depth > 128: # Max depth
		stack.push_back(Bad_Iota.new(ErrorMM.DELVED_TOO_DEEP, "<-Hexecutor->", execution_depth))
		success = false
	elif level_base == null: # No level base, casting disabled
		stack.push_back(Bad_Iota.new(ErrorMM.CASTING_DISABLED, "<-Hexecutor->"))
		success = false
	else: # Execute normally
		if execution_depth == 0 and level_base.is_solvable_level: # If top level and replay 'enabled', add to replay list
			replay_list.push_back(pattern)
		if consideration_mode: # Single meta-pattern mode, see var declaration.
			if stack.size() > 0 and stack[-1] is Pattern_Metalist:
				stack[-1].patterns.push_back(pattern)
			else:
				stack.push_back(pattern) # Append to stack with no list
			consideration_mode = false
			success = true
		elif introspection_depth > 0 and pattern.name != "Consideration": # Multi meta-pattern mode, see var declaration.
			if stack.size() > 0 and stack[-1] is Pattern_Metalist:
				stack[-1].add_pattern(self, pattern)
				success = true
			else:
				printerr("ERROR: Introspection mode enabled, but top of stack is not a Pattern_Metalist!")
				return
		else: # Default mode, just execute the pattern
			success = pattern.execute(self)
			# If success, pattern is a spell, and execution depth is 0, request level validation update (Excluding if in scram mode, from casting enter)
			if success and pattern.is_spell and execution_depth == 0 and not scram_mode:
				main_scene.validate_level()

	# If AFTER meta-execution, charon_mode is true, end hex.
	if charon_mode and execution_depth == 0:
		charon_mode = false
		if is_main_hexecutor: # The execution depth check should prevent this being false, but just in case.
			main_scene.clear() # Wipe grid and stack
		return true # Return early

	# Can choose to only update display on fail. Good for meta-patterns which run many patterns.
	# -- To be clear, update_on_success = false will mean the below 'if' will only run if success is false. (And is_main_hexecutor is true)
	# Additionally, if not is_main_hexecutor, will not run updates. (Useful for oneoff hexecutor instances)
	if (update_on_success or not success) and is_main_hexecutor:
		main_scene.update_hex_display() # Update stack display
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
		if item is Vector2i:
			printerr("WARNING: Vector2i found in stack!")
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
		caster.node.ravenmind = null
		if level_base and level_base.is_solvable_level:
			replay_list.push_back(null) # Null in list represents a grid clear. Keep_raven required as otherwise not "true" grid clear.
	consideration_mode = false
	introspection_depth = 0
