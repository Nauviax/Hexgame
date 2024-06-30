class_name Valid_Patterns
# This class handles identifying and initialising patterns.

# ---------------------- Public Functions ---------------------- #

# Sets the name, validity, p_exe and other data for the given pattern
# On failure, pattern is marked as invalid and some defaults are set.
static func set_pattern_data(pattern: Pattern) -> void:
	var raw_code: String = pattern.p_code.right(-1) # Drop the initial number

	# Check if raw_code is a Numerical Reflection
	if numerical_check(pattern, raw_code):
		pattern.is_valid = true
		pattern.name_internal = Pattern_Enum.numerical_reflection
		pattern.name_display = "Numerical Reflection (" + str(pattern.value) + ")"
		pattern.name_short = "NR(" + str(pattern.value) + ")"
		pattern.is_spell = false
		pattern.p_exe_iota_count = 0
		pattern.descs = numerical_reflection_descs
		pattern.p_exe = numerical_reflection_exe
		return

	# Check if raw_code is a Bookkeeper's Gambit
	if bookkeeper_check(pattern, raw_code):
		pattern.is_valid = true
		pattern.name_internal = Pattern_Enum.bookkeepers_gambit
		pattern.name_display = "Bookkeeper's Gambit (" + value_to_bookkeeper(pattern.value) + ")"
		pattern.name_short = "BG(" + value_to_bookkeeper(pattern.value) + ")"
		pattern.is_spell = false
		pattern.p_exe_iota_count = 0
		pattern.descs = bookkeepers_gambit_descs
		pattern.p_exe = bookkeepers_gambit_exe
		return
	
	# Check if raw_code is a static pattern
	if raw_code in static_patterns:
		pattern.is_valid = true
		var static_data: Array = static_patterns[raw_code]
		pattern.name_internal = static_data[0]
		pattern.name_display = static_data[1]
		pattern.name_short = static_data[2]
		pattern.is_spell = static_data[3]
		pattern.p_exe_iota_count = static_data[4]
		pattern.descs = static_data[5]
		pattern.p_exe = static_data[6]
		return
	
	# Otherwise, pattern is an invalid pattern.
	pattern.is_valid = false
	pattern.name_internal = Pattern_Enum.invalid_pattern
	pattern.name_display = "Invalid Pattern (" + pattern.p_code + ")"
	pattern.name_short = "??(" + pattern.p_code + ")"
	pattern.is_spell = false
	pattern.p_exe_iota_count = 0
	pattern.descs = invalid_pattern_descs
	pattern.p_exe = invalid_pattern_exe
	return

# ---------------------- Dynamic Validation ---------------------- #

# Checks if the given pattern is a Bookkeeper's Gambit
# Bookkeeper's is made from a chain of characters in a specific order.
# If the FIRST character is an "L", we just drew a 1. If it's an "s", we've drawn TWO 0s. (Yes two)
# 	Additionally, if first char is "r" followed by "L", we've drawn a 0 and a 1.
# After drawing a 1, "RL" is another 1, "r" is a 0.
# After drawing a 0, "rL" is a 1, "s" is another 0.
# If at any point (First char, after 1, after 0) the next character(s) do not match these rules, return false.
# 1s and 0s are saved to the value var. To write a single value, bitshift value left by 1 and add 1 or 0.
static func bookkeeper_check(pattern: Pattern, raw_code: String) -> bool:
	# First check empty raw_code. This actually is a valid bookkeeper's gambit.
	if len(raw_code) == 0:
		pattern.value = 0 # A single line just means keep.
		return true

	var value: int = 0 # Value to be written to pattern. In binary, 0 means keep, 1 means toss.
					# The least significant bit is the top of the stack.
	var ii: int = 0 # Char being read
	var state: int = 2 # Represents last drawn value. 0 = 0, 1 = 1, 2 = start.
	while ii < len(raw_code):
		match state:
			2: # Starting state
				match raw_code[ii]:
					"L":
						state = 1
						value = 1 # 1
					"s":
						state = 0
						value = 0 # 00
					"r":
						ii += 1
						if ii < len(raw_code) and raw_code[ii] == "L":
							state = 1
							value = 1 # 01
						else:
							return false
					_:
						return false
			1: # Last drawn value was 1 (Delete)
				match raw_code[ii]:
					"R":
						ii += 1
						if ii < len(raw_code) and raw_code[ii] == "L":
							state = 1
							value = (value << 1) + 1 # 1
						else:
							return false
					"r":
						state = 0
						value = value << 1 # 0
					_:
						return false
			0: # Last drawn value was 0 (Keep)
				match raw_code[ii]:
					"r":
						ii += 1
						if ii < len(raw_code) and raw_code[ii] == "L":
							state = 1
							value = (value << 1) + 1 # 1
						else:
							return false
					"s":
						state = 0
						value = value << 1 # 0
					_:
						return false
		ii += 1
	# If we get here, we have a valid bookkeeper's gambit.
	pattern.value = value # NOTE: Value is converted to a float here. This MAY cause issues, but is probably fine.
	return true

# Checks if the given pattern is a Numerical Reflection
# Check is done by viewing first 4 characters of raw_code
# Will set name and value of pattern on match.
static func numerical_check(pattern: Pattern, raw_code: String) -> bool:
	# First check that raw_code is at least 4 characters long
	if len(raw_code) < 4:
		return false
	# Then check if first 4 characters match a numerical reflection
	if raw_code.left(4) == "LlLL":
		pattern.value = calculate_num(raw_code.right(-4))
		return true
	elif raw_code.left(4) == "RrRR":
		pattern.value = calculate_num(raw_code.right(-4)) * -1
		return true
	else:
		return false

# Calculates the numeric value of a numerical reflection.
# Pass in only the dynamic part of the code. Not the entire raw_code.
# Returns only positive values.
static func calculate_num(code: String) -> float:
	var value: float = 0.0
	for cc in code:
		match cc:
			"L":
				value *= 2.0
			"l":
				value += 5.0
			"s":
				value += 1.0
			"r":
				value += 10.0
			"R":
				value /= 2.0
	return value

# Helper function to convert a value (number) to a bookkeeper's gambit string
static func value_to_bookkeeper(value: float) -> String:
	var val_clone: int = int(value) # May cause problems for large values, when converting float to int. Seems fine for now though.
	var str_gambit: String = ""
	# Treat value as binary, if bit is 1, add "x" to string, if bit is 0, add "-" to string
	while val_clone > 0:
		if val_clone % 2 == 1:
			str_gambit = "x" + str_gambit
		else:
			str_gambit = "-" + str_gambit
		val_clone = val_clone >> 1
	if str_gambit == "": # For the do-nothing gambit
		str_gambit = "-"
	return str_gambit

# ---------------------- Pattern Internal Names Enum ---------------------- #

enum Pattern_Enum {
	# Dynamic Patterns
	numerical_reflection, bookkeepers_gambit, invalid_pattern,

	# Basic Patterns
	compass_purification, minds_reflection, alidades_purification,
	pace_purification, reveal, archers_distillation,
	architects_distillation, scouts_distillation,

	# Mathematics
	length_purification, additive_distillation, subtractive_distillation,
	multiplicative_distillation, division_distillation, ceiling_purification,
	floor_purification, axial_purification, vector_distillation,
	vector_decomposition, modulus_distillation, power_distillation,
	entropy_reflection,

	# Constants
	eulers_reflection, arcs_reflection, circles_reflection,
	false_reflection, true_reflection, nullary_reflection,
	vector_reflection_zero, vector_reflection_neg_x, vector_reflection_pos_x,
	vector_reflection_neg_y, vector_reflection_pos_y,

	# Stack Manipulation
	dioscuri_gambit, gemini_decomposition, gemini_gambit,
	fishermans_gambit, fishermans_gambit_ii,
	prospectors_gambit, rotation_gambit, rotation_gambit_ii,
	flocks_reflection, jesters_gambit, swindlers_gambit,
	undertakers_gambit,

	# Logical Operators
	conjunction_distillation, augurs_purification, equality_distillation,
	maximus_distillation, maximus_distillation_ii, augurs_exaltation,
	minimus_distillation, minimus_distillation_ii, negation_purification,
	inequality_distillation, disjunction_distillation, exclusion_distillation,
    
	# Entities
	entity_purification, zone_distillation,

	# List Manipulation
	integration_distillation, derivation_decomposition, speakers_distillation,
	speakers_decomposition, vacant_reflection, selection_distillation,
	selection_exaltation, locators_distillation, flocks_gambit,
	flocks_disintegration, excisors_distillation, surgeons_exaltation,
	retrograde_purification, singles_purification,

	# Escaping Patterns
	consideration, introspection, retrospection, evanition,

	# Reading and Writing
	scribes_reflection, scribes_gambit, chroniclers_purification,
	chroniclers_gambit, auditors_purification, assessors_purification,
	huginns_gambit, muninns_reflection,

	# Advanced Mathematics
	cosine_purification, sine_purification, tangent_purification,
	inverse_cosine_purification, inverse_sine_purification, inverse_tangent_purification,
	inverse_tangent_purification_ii, logarithmic_distillation,

    # Sets
    uniqueness_purification,

    # Meta-Evaluation
    hermes_gambit, charons_gambit, thoths_gambit,

    ## ADDONS ##

    # Hexal Math
    factorial_purification, running_sum_purification, running_product_purification,

    ### NEW PATTERNS ###

    # Level access
    enter, exit,

    # Spellbook
    versos_gambit, rectos_gambit, tomes_gambit,

    ## SPELLS ##

    # Sentinel
    summon_sentinel, banish_sentinel, locate_sentinel, wayfind_sentinel,

    # Other
    explosion, impulse, levitate, teleport,
	
}

# ---------------------- Descriptions and Callables ---------------------- #

# Dynamic descriptions first, to get them out of the way.

static var numerical_reflection_descs: Array = [
	"Represents and returns a number, determined by the exact pattern drawn. See next desc for more.",
	"Draw initial diamond clockwise for negative, counter for positive. Then for each possible direction left to right: L = x2, l = 5, s = 1, r = 10, R = /2."
]
# Adds the numerical pattern value to the stack
static func numerical_reflection_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.stack.push_back(pattern.value)
	return true

static var bookkeepers_gambit_descs: Array = [
	"Removes iotas from the stack based on the exact pattern drawn. '-' represents keep, '\\/' represents remove. Last drawn keep/remove affects the top of stack.",
]
# Remove iotas from stack based on value
# Value as a binary number will look something like 10101, where 1 means remove and 0 means keep.
# The rightmost/least significant bit is the top of the stack/last item in list.
static func bookkeepers_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var value: int = int(pattern.value) # May cause problems if float is large, but seems fine so far. (Like 29.9999 -> 29 or smth dumb)
	# Ensure stack is large enough to remove items
	var count: int = int(log(value) / log(2)) + 1
	if count > stack.size():
		# Add garbage to BOTTOM of stack until it is large enough
		for ii in range(stack.size(), count):
			stack.push_front(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, pattern.name_display, count, count - stack.size() - 1))
		return false
	
	# Remove the specified items from the stack
	var target: int = stack.size() - 1 # Start at top of stack
	while value > 0: # More items to remove
		if value % 2 == 1:
			stack.pop_at(target)
		target -= 1
		value = value >> 1
	return true

static var invalid_pattern_descs: Array = [
	"Created when no defined functionality is tied to the given pattern. Will return an error if cast.",
]
# Adds a trash iota to the stack
static func invalid_pattern_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.INVALID_PATTERN, pattern.name_display, pattern.p_code))
	return false

# And now the static descriptions and callables. Same order as shown in the static_patterns dictionary.

# ----- Basic Patterns -----

static var compass_purification_descs: Array = [
	"Given an entity, returns the tile position of the entity.",
]
# Turns an entity on the stack into it's position
static func compass_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.get_fake_pos())
		hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
		return true
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false

static var minds_reflection_descs: Array = [
	"Returns the caster as an entity iota.",
]
# Adds the caster to the stack as an entity iota
static func minds_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(hexecutor.caster)
	return true

static var alidades_purification_descs: Array = [
	"Given an entity, returns the vector direction it's looking in.",
]
# Turns an entity on the stack into the direction it's looking
static func alidades_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.look_dir)
		hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
		return true
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false

static var pace_purification_descs: Array = [
	"Given an entity, returns it's velocity vector. Most of the time, this will be (0,0).",
]
# Turns an entity on the stack into it's velocity (Tiles per second hopefully)
static func pace_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	# Check that the popped value is an entity
	if entity is Entity:
		stack.push_back(entity.get_fake_vel())
		hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
		return true
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false

static var reveal_descs: Array = [
	"This pattern copies the top iota and saves it to the level. Many levels will require you to reveal a specific iota to beat them.",
]
# Reveals the top value of the stack.
# This will save the iota to level_base, which then gets displayed by hex_display.
static func reveal_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.log_spellbook_change(11) # Revealed iota is changed
	hexecutor.level_base.revealed_iota = hexecutor.stack[-1]
	return true

static var archers_distillation_descs: Array = [
	"Given a position (SECOND) and a direction (TOP), returns the centre tile coordinates hit by a raycast, or null if no hit. Max distance 16 tiles. Ignores glass and entities.",
]
# Takes a position (b) and a direction (a) and returns the tile hit by the raycast.
# Tile position is returned in fake coordinates, representing the centre of the tile hit. (Or null if no tile was hit)
# Raycast distance should be 16 tiles.
static func archers_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var dir: Variant = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", dir))
		return false
	dir = dir.normalized()
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base: Level_Base = hexecutor.level_base # Used to do raycasting
	var fake_pos: Variant = level_base.block_raycast(pos, dir)
	stack.push_back(fake_pos) # Return fake coords of tile hit
	# Particles
	if fake_pos:
		var real_pos: Vector2 = Entity.fake_to_real(fake_pos)
		hexecutor.caster.node.particle_target(real_pos)
		hexecutor.caster.node.particle_trail(pos, real_pos - pos)
	else:
		hexecutor.caster.node.particle_trail(pos, dir * Entity.FAKE_SCALE) # Raycast distance 1 tile
	return true

static var architects_distillation_descs: Array = [
	"Given a position (SECOND) and a direction (TOP), returns the normal of the tile hit by a raycast, or null if no tile was hit. Max distance 16 tiles. Ignores glass and entities.",
]
# Takes a position (b) and a direction (a) and returns the SIDE of the tile hit by the raycast, or null if none is found.
# If this hits the south face of a tile, it would return (0, 1) 
static func architects_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var dir: Variant = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", dir))
		return false
	dir = dir.normalized()
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base: Level_Base = hexecutor.level_base # Used to do raycasting
	var results: Variant = level_base.block_side_raycast(pos, dir)
	if results:
		stack.push_back(results[0]) # Return normal of tile hit
		hexecutor.caster.node.particle_target(results[1])
		hexecutor.caster.node.particle_trail(pos, results[1] - pos)
	else:
		stack.push_back(null) # No tile hit
		hexecutor.caster.node.particle_trail(pos, dir * Entity.FAKE_SCALE) # Raycast distance 1 tile
	return true


static var scouts_distillation_descs: Array = [
	"Given a position (SECOND) and a direction (TOP), returns the entity hit by a raycast, or null if no entity was hit. Max distance 16 tiles. Ignores glass, but NOT walls.",
]
# Takes a position (b) and a direction (a) and returns the ENTITY hit by the raycast, or null if none is found.
# If the raycast hits a wall, returns null.
static func scouts_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var dir: Variant = stack.pop_back()
	if not dir is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", dir))
		return false
	dir = dir.normalized()
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var level_base: Level_Base = hexecutor.level_base # Used to do raycasting
	var entity: Variant = level_base.entity_raycast(pos, dir)
	stack.push_back(entity) # Return entity
	# Particles
	if entity:
		var entity_pos: Vector2 = entity.get_pos()
		hexecutor.caster.node.particle_target(entity_pos)
		hexecutor.caster.node.particle_trail(pos, entity_pos - pos)
	else:
		hexecutor.caster.node.particle_trail(pos, dir * Entity.FAKE_SCALE) # Raycast distance 1 tile
	return true

# ----- Mathematics -----

static var length_purification_descs: Array = [
	"Given a number, returns its absolute value. Given a vector, returns its length.",
	"Given a boolean, returns 0.0 for false, 1.0 for true.",
	"Given a list, returns the number of elements in it.",
]
# Replaces a number with its absolute value, or a vector with its length.
# Additionally, converts boolean values to 0.0 (f) or 1.0 (t).
# Additionallier, converts arrays to their size.
static func length_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is Vector2:
		stack.push_back(iota.length())
	elif iota is float:
		stack.push_back(abs(iota))
	elif iota is bool:
		stack.push_back(1.0 if iota else 0.0)
	elif iota is Array:
		stack.push_back(float(iota.size()))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "(Many)", iota))
		return false
	return true

static var additive_distillation_descs: Array = [
	"Given two numbers or vectors, returns their sum. Given one of each, adds the number to each component of the vector.",
	"Given two lists, appends the TOP list to the end of the SECOND list.",
]
# Takes the top two iotas in stack, returns the sum
# For Arrays, appends list aa to the end of list bb
static func additive_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(aa + bb)
	elif aa is Vector2 and bb is Vector2:
		aa += bb
		stack.push_back(aa)
	elif aa is float and bb is Vector2:
		bb.x += aa
		bb.y += aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		aa.x += bb
		aa.y += bb
		stack.push_back(aa)
	elif aa is Array and bb is Array:
		bb += aa
		stack.push_back(bb)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var subtractive_distillation_descs: Array = [
	"Given two numbers or vectors, returns SECOND - TOP. Given a number TOP, and a vector SECOND, subtracts TOP from each component of SECOND.",
]
# Takes the top two iotas in stack, returns b - a (a being the top iota)
static func subtractive_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(bb - aa)
	elif aa is Vector2 and bb is Vector2:
		bb -= aa
		stack.push_back(bb)
	elif aa is float and bb is Vector2:
		bb.x -= aa
		bb.y -= aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true


static var multiplicative_distillation_descs: Array = [
	"Given two numbers, returns their product. Given a number and a vector, scales the vector by the number.",
	"Given two vectors, returns their dot product.",
]
# Takes the top two iotas in stack, returns the product.
# With two vectors, returns the dot product.
static func multiplicative_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(aa * bb)
	elif aa is Vector2 and bb is Vector2:
		return aa.dot(bb)
	elif aa is float and bb is Vector2:
		bb.x *= aa
		bb.y *= aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		aa.x *= bb
		aa.y *= bb
		stack.push_back(aa)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var division_distillation_descs: Array = [
	"Given two numbers, returns SECOND / TOP. Given a number (TOP) and a vector (SECOND), divides each vector component by the number.",
	"Given two vectors, returns the 2D cross product, SECOND x TOP. Specifically, returns the Z component of the cross product vector, assuming the Z values of the input vectors are 0. Example: (1,2) x (1,-3) -> (0,0,-5) -> return -5."
]
# Takes the top two iotas in stack, returns returns b / a (a being the top iota)
# With two vectors, returns the 2D cross product.
#   Obviously a 2D cross product isn't possible
#   This code returns the SIGNED magnitude (z) of the cross product vector, assuming a and b's Z values are 0
#   Can be used to determine whether rotating from b to a moves in a counter clockwise or clockwise direction
#   See "stackoverflow.com/questions/243945"
static func division_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		if aa == 0:
			stack.push_back(Bad_Iota.new(ErrorMM.DIV_BY_ZERO, pattern.name_display))
			return false
		else:
			stack.push_back(bb / aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back((bb.x * aa.y) - (bb.y * aa.x))
	elif aa is float and bb is Vector2:
		if aa == 0:
			stack.push_back(Bad_Iota.new(ErrorMM.DIV_BY_ZERO, pattern.name_display))
			return false
		else:
			bb.x /= aa
			bb.y /= aa
			stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var ceiling_purification_descs: Array = [
	"Given a number or vector, rounds it UP to an integer and returns it. Vector components are rounded up individually to create a new vector.",
]
# Ceilings the top iota of the stack
# For vectors, ceil each element
static func ceiling_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is float:
		stack.push_back(ceil(iota))
	elif iota is Vector2:
		stack.push_back(Vector2(ceil(iota.x), ceil(iota.y)))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number/vector", iota))
		return false
	return true

static var floor_purification_descs: Array = [
	"Given a number or vector, rounds it DOWN to an integer and returns it. Vector components are rounded down individually to create a new vector.",
]
# Floors the top iota of the stack
# For vectors, floors each element
static func floor_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is float:
		stack.push_back(floor(iota))
	elif iota is Vector2:
		stack.push_back(Vector2(floor(iota.x), floor(iota.y)))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number/vector", iota))
		return false
	return true

static var axial_purification_descs: Array = [
	"Given a vector, returns the nearest axial direction as a unit vector. Given a number, returns 1 if positive, -1 if negative. In both cases, zero is unaffected.",
]
# For a vector, coerce it to its nearest axial direction, a unit vector.
# For a number, return the sign of the number; 1 if positive, -1 if negative.
# In both cases, zero is unaffected.
static func axial_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is float:
		if iota > 0:
			stack.push_back(1.0)
		elif iota < 0:
			stack.push_back(-1.0)
		else:
			stack.push_back(0.0)
	elif iota is Vector2:
		var unitVector: Vector2 = Vector2(0, 0) # Default 0,0 if x == y == 0
		var xx: float = iota.x
		var yy: float = iota.y
		if xx == 0 and yy == 0:
			stack.push_back(unitVector) # Just push 0,0.
			return true
		if xx > yy:
			unitVector.x = 1 if iota.x > 0 else -1
		elif xx <= yy: # On tie, y wins.
			unitVector.y = 1 if iota.y > 0 else -1
		stack.push_back(unitVector)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number/vector", iota))
		return false
	return true

static var vector_distillation_descs: Array = [
	"Given two numbers TOP (y) and SECOND (x), returns a vector (SECOND, TOP).",
]
# Takes two numbers and creates a vector. (b, a) where a is on top of the stack.
# This means adding 1 then 2 to stack then executing, (So 2 is on top,) will give (1, 2).
static func vector_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(Vector2(bb, aa))
	return true

static var vector_decomposition_descs: Array = [
	"Given a vector, returns the components of the vector. Return order is x then y, so y will be on top of stack.",
]
# Takes a vector of two values and pushes the contents to the stack.
# For vector [x, y], x is pushed first, then by. (Leaving y on top)
static func vector_decomposition_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var vector: Variant = stack.pop_back()
	if vector is Vector2:
		stack.push_back(vector.x)
		stack.push_back(vector.y)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", vector))
		return false
	return true

static var modulus_distillation_descs: Array = [
	"Given two numbers, returns the modulus of the SECOND number by the TOP number. (5 % 3 is 2)",
	"Given a vector (SECOND) and a number (TOP), preforms the modulus on each vector component.",
]
# Takes the modulus of two numbers. (5 % 3 is 2)
# When applied on vectors, performs the above operation elementwise
static func modulus_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(fmod(bb, aa))
	elif aa is Vector2 and bb is Vector2:
		bb.x = fmod(bb.x, aa.x)
		bb.y = fmod(bb.y, aa.y)
		stack.push_back(bb)
	elif aa is float and bb is Vector2:
		bb.x = fmod(bb.x, aa)
		bb.y = fmod(bb.y, aa)
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var power_distillation_descs: Array = [
	"Given two numbers, raises the SECOND number to the power of the TOP number.",
	"Given a number (TOP) and a vector (SECOND), raises each component of the vector to the power of the number.",
	"Given two vectors, returns the vector projection of the TOP vector onto the SECOND vector."
]
# With two numbers, combines them by raising bb to the power of aa. (aa is top of stack)
# With a number and a vector, raises each component of the vector to the number's power.
# With two vectors, combines them into the vector projection of aa onto bb.
static func power_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	# Ensure that both values are floats or vectors
	if aa is float and bb is float:
		stack.push_back(bb ** aa)
	elif aa is Vector2 and bb is Vector2:
		stack.push_back(aa.project(bb))
	elif aa is float and bb is Vector2:
		bb.x = bb.x ** aa
		bb.y = bb.y ** aa
		stack.push_back(bb)
	elif aa is Vector2 and bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var entropy_reflection_descs: Array = [
	"Returns a random number between 0 (inc) and 1 (exc), rounded to 2 decimal places. (rand(0, 99) / 100.0)",
]
# Adds a random number between 0 and 1, rounded to 2 decimal places, to the stack.
static func entropy_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(randi_range(0, 99) / 100.0)
	return true

# ----- Constants -----

static var eulers_reflection_descs: Array = [
	"Returns e, the base of natural logarithms.",
]
# Returns e, the base of natural logarithms
static func eulers_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(exp(1))
	return true

static var arcs_reflection_descs: Array = [
	"Returns π, the radial representation of half a circle.",
]
# Returns π, the radial representation of half a circle
static func arcs_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(PI)
	return true

static var circles_reflection_descs: Array = [
	"Returns τ, the radial representation of a complete circle.",
]
# Returns τ, the radial representation of a complete circle
static func circles_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(TAU)
	return true

static var false_reflection_descs: Array = [
	"Returns false, a boolean value.",
]
# Pushes false (Boolean)
static func false_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(false)
	return true

static var true_reflection_descs: Array = [
	"Returns true, a boolean value.",
]
# Pushes true (Boolean)
static func true_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(true)
	return true

static var nullary_reflection_descs: Array = [
	"Returns null.",
]
# Pushes null
static func nullary_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(null)
	return true

static var vector_reflection_zero_descs: Array = [
	"Returns an empty vector. (0, 0)",
]
# Pushes (0,0)
static func vector_reflection_zero_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Vector2(0.0, 0.0))
	return true

static var vector_reflection_neg_x_descs: Array = [
	"Returns a vector pointing left. (-1, 0)",
]
# Pushes (-1,0)
static func vector_reflection_neg_x_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Vector2(-1.0, 0.0))
	return true

static var vector_reflection_pos_x_descs: Array = [
	"Returns a vector pointing right. (1, 0)",
]
# Pushes (1,0)
static func vector_reflection_pos_x_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Vector2(1.0, 0.0))
	return true

static var vector_reflection_neg_y_descs: Array = [
	"Returns a vector pointing up. (0, -1)",
]
# Pushes (0,-1)
static func vector_reflection_neg_y_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Vector2(0.0, -1.0))
	return true

static var vector_reflection_pos_y_descs: Array = [
	"Returns a vector pointing down. (0, 1)",
]
# Pushes (0,1)
static func vector_reflection_pos_y_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Vector2(0.0, 1.0))
	return true

# ----- Stack Manipulation -----

static var dioscuri_gambit_descs: Array = [
	"Returns copies of the top two iotas, resulting in two copies of each. Both copies are placed above both originals on the stack.",
]
# Duplicates the top two iotas on the stack.
static func dioscuri_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	if bb is Array:
		stack.push_back(bb.duplicate(true)) # Deep copy
	else:
		stack.push_back(bb)
	if aa is Array:
		stack.push_back(aa.duplicate(true)) # Deep copy
	else:
		stack.push_back(aa)
	return true

static var gemini_decomposition_descs: Array = [
	"Returns a copy of the top iota, resulting in two of that iota.",
]
# Duplicates the top iota of the stack.
static func gemini_decomposition_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	stack.push_back(aa)
	if aa is Array:
		stack.push_back(aa.duplicate(true)) # Deep copy
	else:
		stack.push_back(aa)
	return true

static var gemini_gambit_descs: Array = [
	"Given a number (TOP) and an iota (SECOND), returns num copies of the second iota. Caps at 1000 copies.",
]
# Takes a number (top) and an iota, then pushes num copies of iota onto the stack.
# (A count of 2 results in two of the iota on the stack, not three.)
# num > 1000 will fail.
# This pattern has a side effect of creating only duplicates, the original array is lost.
# Shouldn't ever be a problem, but it's worth noting.
static func gemini_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	if num < 0 or num > 1000:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 1000, num))
		return false
	var iota: Variant = stack.pop_back()
	if iota is Array:
		for ii in range(num):
			stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		for ii in range(num):
			stack.push_back(iota)
	return true

static var fishermans_gambit_descs: Array = [
	"Given a number, REMOVES the iota at that index in the stack and returns it to the top. If negative, instead moves the top iota down 'number' places.",
	"0 refers to the top of the stack, which is the number that gets removed. 1 would just bring the (now) top element to the top. Both of these inputs will do nothing."
]
# Grabs the element in the stack indexed by the number iota (top of stack) and brings it to the top.
# If the number is negative, instead moves the top element of the stack down that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. This element is consumed, so do nothing.
# 1 effectively does nothing, as it just brings the top element to the top.
static func fishermans_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	if num == 0: # 0 refers to the top of stack, which is num. It's consumed, so do nothing.
		return true
	if num < 0: # Negative number, move top iota down
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota: Variant = stack.pop_back()
		stack.insert(stack.size() + num, iota)
	else: # Positive number, move element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota: Variant = stack.pop_at(stack.size() - num)
		stack.push_back(iota)
	return true

static var fishermans_gambit_ii_descs: Array = [
	"Given a number, COPIES the iota at that index in the stack and returns it to the top. If negative, instead inserts a copy of top iota below 'number' iotas in stack.",
	"0 refers to the top of the stack, which means the removed number just gets copied back. 1 will simply duplicate the (now) top element to just below it."
]
# READS the element in the stack indexed by the number iota (top of stack) and COPIES it to the top.
# If the number is negative, instead copies the top element of the stack below that many elements.
# 0 refers to the top of stack, which gets removed/consumed by this pattern. Return the number to the stack and finish.
# 1 effectively duplicates the top element to the top.
static func fishermans_gambit_ii_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	if num == 0: # 0 refers to the top of stack, which is num. So give it back and finish.
		stack.push_back(num)
		return true
	if num < 0: # Negative number, copy top iota below num elements
		if num * -1 >= stack.size(): # Can't push to non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota: Variant = stack[-1]
		if iota is Array:
			stack.insert(stack.size() - 1 + num, iota.duplicate(true)) # Deep copy
		else:
			stack.insert(stack.size() - 1 + num, iota) # -1 as stack size is larger than normal fisherman's gambit
		
	else: # Positive number, copy element at index to top
		if num > stack.size(): # Can't get non-existent index
			stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, -stack.size()+1, stack.size(), num))
			return false
		var iota: Variant = stack[stack.size() - num]
		if iota is Array:
			stack.push_back(iota.duplicate(true)) # Deep copy
		else:
			stack.push_back(iota)
	return true

static var prospectors_gambit_descs: Array = [
	"Copies the second iota in the stack, then pastes it to the top. [second, TOP] becomes [second, TOP, second].",
]
# Copy the second-to-last iota of the stack to the top. [b, a] (a is top) becomes [b, a, b].
static func prospectors_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	stack.push_back(bb)
	return true

static var rotation_gambit_descs: Array = [
	"Takes the third iota from the top, and brings it to the top of the stack. [third, second, TOP] becomes [second, TOP, third].",
]
# Yanks the iota third from the top of the stack to the top. [cc, bb, aa] becomes [bb, aa, cc]
static func rotation_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	var cc: Variant = stack.pop_back()
	stack.push_back(bb)
	stack.push_back(aa)
	stack.push_back(cc)
	return true

static var rotation_gambit_ii_descs: Array = [
	"Takes the top iota and brings it to the third position. [third, second, TOP] becomes [TOP, third, second].",
]
# Yanks the top iota to the third position. [cc, bb, aa] becomes [aa, cc, bb]
static func rotation_gambit_ii_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	var cc: Variant = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(cc)
	stack.push_back(bb)
	return true

static var flocks_reflection_descs: Array = [
	"Returns the size of the stack to the stack.",
]
# Returns the size of the stack to the stack
static func flocks_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	stack.push_back(float(stack.size()))
	return true

static var jesters_gambit_descs: Array = [
	"Takes the top two iotas and swaps their positions on the stack.",
]
# Swaps the top two iotas on the stack
static func jesters_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(bb)
	return true

static var swindlers_gambit_descs: Array = [
	"Given a number (TOP) Rearranges the rest of the top elements on the stack based on the given numerical code (TOP). See 'Lehmer codes' for info, or see next desc.",
    "This game only supports rearranging up to 5 elements, based on those at github.com/FallingColors/HexMod/wiki/Table-of-Lehmer-Codes-for-Swindler's-Gambit. Good luck copying that link though.", # !!! Include a link to ingame resource later somehow?
    "An example of what to expect: given a stack 'cba' where a is top iota, code 0 gives cba, 1 -> cab, 2 -> bca, 3 -> bac, 4 -> acb, 5 -> abc etc. etc. This goes on for a long time.",
]
# Rearranges the top elements of the stack based on the given numerical code,
#    which is the index of the permutation wanted. (Lehmer codes)
# See https://github.com/FallingColors/HexMod/wiki/Table-of-Lehmer-Codes-for-Swindler's-Gambit
# With a as top of stack: (cba for 3 large stack)
# 0	a (cba)
# 1	ab (cab)
# 2	bca
# 3	bac
# 4	acb
# 5	abc
# (This goes on for a long time)
static func swindlers_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	if num < 0 or num > 119:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, 119, num))
		return false
	var code: String = swindlers_lehmer[int(num)]
	var iotas: Array = [] # Stored in order abcde (flipped compared to lehmer code)
	# Ensure enough iotas
	if len(code) > stack.size():
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, pattern.name_display, len(code), stack.size()))
		return false
	# Rearrange elements and return
	for ii in range(len(code)):
		iotas.append(stack.pop_back())
	for ii in code:
		match ii:
			"a":
				stack.push_back(iotas[0])
			"b":
				stack.push_back(iotas[1])
			"c":
				stack.push_back(iotas[2])
			"d":
				stack.push_back(iotas[3])
			"e":
				stack.push_back(iotas[4])
	return true
# Input order edcba where a is top of stack
# This might be better as an array, but it's at least a bit more readable this way.
static var swindlers_lehmer: Dictionary = {
	0 : "a", 1 : "ab", 2 : "bca", 3 : "bac", 4 : "acb",
    5 : "abc", 6 : "cdba",  7 : "cdab", 8 : "cbda", 9 : "cbad",
    10 : "cadb", 11 : "cabd", 12 : "bdca", 13 : "bdac", 14 : "bcda",
    15 : "bcad", 16 : "badc", 17 : "bacd", 18 : "adcb", 19 : "adbc",
    20 : "acdb", 21 : "acbd", 22 : "abdc", 23 : "abcd", 24 : "decba",
    25 : "decab", 26 : "debca", 27 : "debac", 28 : "deacb", 29 : "deabc",
    30 : "dceba", 31 : "dceab", 32 : "dcbea", 33 : "dcbae", 34 : "dcaeb",
    35 : "dcabe", 36 : "dbeca", 37 : "dbeac", 38 : "dbcea", 39 : "dbcae",
    40 : "dbaec", 41 : "dbace", 42 : "daecb", 43 : "daebc", 44 : "daceb",
    45 : "dacbe", 46 : "dabec", 47 : "dabce", 48 : "cedba", 49 : "cedab",
    50 : "cebda", 51 : "cebad", 52 : "ceadb", 53 : "ceabd", 54 : "cdeba",
    55 : "cdeab", 56 : "cdbea", 57 : "cdbae", 58 : "cdaeb", 59 : "cdabe",
    60 : "cbeda", 61 : "cbead", 62 : "cbdea", 63 : "cbdae", 64 : "cbaed",
    65 : "cbade", 66 : "caedb", 67 : "caebd", 68 : "cadeb", 69 : "cadbe",
    70 : "cabed", 71 : "cabde", 72 : "bedca", 73 : "bedac", 74 : "becda",
    75 : "becad", 76 : "beadc", 77 : "beacd", 78 : "bdeca", 79 : "bdeac",
    80 : "bdcea", 81 : "bdcae", 82 : "bdaec", 83 : "bdace", 84 : "bceda",
    85 : "bcead", 86 : "bcdea", 87 : "bcdae", 88 : "bcaed", 89 : "bcade",
    90 : "baedc", 91 : "baecd", 92 : "badec", 93 : "badce", 94 : "baced",
    95 : "bacde", 96 : "aedcb", 97 : "aedbc", 98 : "aecdb", 99 : "aecbd",
    100 : "aebdc", 101 : "aebcd", 102 : "adecb", 103 : "adebc", 104 : "adceb",
    105 : "adcbe", 106 : "adbec", 107 : "adbce", 108 : "acedb", 109 : "acebd",
    110 : "acdeb", 111 : "acdbe", 112 : "acbed", 113 : "acbde", 114 : "abedc",
    115 : "abecd", 116 : "abdec", 117 : "abdce", 118 : "abced", 119 : "abcde"
} 

static var undertakers_gambit_descs: Array = [
	"Copies the top iota of the stack, then pastes it under the second iota. [second, TOP] becomes [TOP, second, TOP].",
]
# Copy the top iota of the stack, then put it under the second iota. [bb, aa] (aa is top) becomes [aa, bb, aa].
static func undertakers_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	stack.push_back(aa)
	stack.push_back(bb)
	stack.push_back(aa)
	return true

# ----- Logical Operators -----

static var conjunction_distillation_descs: Array = [
	"Given two booleans, returns True if both are True, otherwise False.",
	"Given two numbers, returns a number containing every bit that is 'on' in both numbers. Ignores decimal part of inputs.",
	"Given two lists, returns a list containing every unique element that exists in BOTH lists."
]
# Returns True if both arguments are true; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit present in both bitsets.
# With two lists, this creates a SET with every unique element that exists in BOTH lists.
# (AND)
static func conjunction_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	if aa is bool and bb is bool:
		stack.push_back(aa and bb)
	elif aa is float and bb is float:
		aa = int(aa)
		bb = int(bb)
		stack.push_back(float(aa & bb))
	elif aa is Array and bb is Array:
		var result: Array = []
		for iota: Variant in aa:
			if (iota in bb) and (not iota in result):
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var augurs_purification_descs: Array = [
	"Given an iota, converts it to a boolean. 0, Null, and empty list are false, ANYTHING else is true.",
]
# Converts iota to boolean
# 0, Null, and empty list (Normal or meta pattern) are false, ANYTHING else is true
static func augurs_purification_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is float:
		stack.push_back(iota != 0)
	elif iota is Array:
		stack.push_back(iota.size() != 0)
	else:
		stack.push_back(iota != null)
	return true

static var equality_distillation_descs: Array = [
	"Given two booleans, returns True if they are equal, and False otherwise.",
	"Given two numbers, returns True if they are equal (within a small tolerance, 0.0001), and False otherwise.",
	"Given two lists, returns True if they are the same, and False otherwise. (By value, not by reference.)"
]
# If the first argument equals the second (within a small tolerance, 0.0001), return True. Otherwise, return False.
# (~=)
static func equality_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	if (aa is bool and bb is bool) or (aa is Array and bb is Array):
		stack.push_back(aa == bb)
	elif aa is float and bb is float:
		stack.push_back(abs(aa - bb) < 0.0001)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var maximus_distillation_descs: Array = [
	"Given two numbers, return True if the TOP number is greater than the SECOND, and False otherwise.",
]
# If the first argument is greater than the second, return True. Otherwise, return False.
# (>)
static func maximus_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(aa > bb)
	return true

static var maximus_distillation_ii_descs: Array = [
	"Given two numbers, return True if the TOP number is greater than or equal to the SECOND, and False otherwise.",
]
# If the first argument is greater than or equal to the second, return True. Otherwise, return False.
# (>=)
static func maximus_distillation_ii_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(aa >= bb)
	return true

static var augurs_exaltation_descs: Array = [
	"If the TOP iota is True, keeps the second iota and discards the third; Otherwise discards the second and keeps the third.",
]
# If the first argument is True, keeps the second and discards the third; otherwise discards the second and keeps the third.
# (IF)
static func augurs_exaltation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if aa is bool:
		var bb: Variant = stack.pop_back()
		var cc: Variant = stack.pop_back()
		if aa:
			stack.push_back(bb)
		else:
			stack.push_back(cc)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "bool", aa))
		return false
	return true

static var minimus_distillation_descs: Array = [
	"Given two numbers, return True if the TOP number is less than the SECOND, and False otherwise.",
]
# If the first argument is less than the second, return True. Otherwise, return False.
# (<)
static func minimus_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(aa < bb)
	return true

static var minimus_distillation_ii_descs: Array = [
	"Given two numbers, return True if the TOP number is less than or equal to the SECOND, and False otherwise.",
]
# If the first argument is less than or equal to the second, return True. Otherwise, return False.
# (<=)
static func minimus_distillation_ii_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(aa <= bb)
	return true

static var negation_purification_descs: Array = [
	"Given a boolean, returns the opposite boolean. (true -> false, etc.)",
	"Given a number, returns the bitwise inversion of the number. (0 -> -1, -100 -> 99, 0b001100 -> 0b110011 etc.)",
]
# If iota is true, return false. If iota is false, return true.
# For numbers, Takes the inversion of the bitset. For example, 0 will become -1, and -100 will become 99.
static func negation_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	if iota is bool:
		stack.push_back(not iota)
	elif iota is float:
		iota = int(iota)
		stack.push_back(float(~iota))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number/bool", iota))
		return false
	return true

static var inequality_distillation_descs: Array = [
	"Given two booleans, returns True if they are not equal, and False otherwise.",
	"Given two numbers, returns True if they are not equal (within a small tolerance, 0.0001), and False otherwise.",
	"Given two lists, returns True if they are not the same, and False otherwise. (By value, not by reference.)",
]
# If the first argument does NOT equals the second (within a small tolerance, 0.0001), return True. Otherwise, return False.
# (!~=)
static func inequality_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	if (aa is bool and bb is bool) or (aa is Array and bb is Array):
		stack.push_back(not (aa == bb))
	elif aa is float and bb is float:
		stack.push_back(not (abs(aa - bb) < 0.0001))
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var disjunction_distillation_descs: Array = [
	"Given two booleans, returns True if at least one of the arguments are True; otherwise returns False.",
	"Given two numbers, returns a number containing every 'on' bit in either number. Ignores decimal part of inputs.",
	"Given two lists, returns a list containing every unique element from the two lists."
]
# Returns True if at least one of the arguments are True; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit in either bitset.
# With two lists, this creates a SET with every unique element from the two lists.
# (OR)
static func disjunction_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	if aa is bool and bb is bool:
		stack.push_back(aa or bb)
	elif aa is float and bb is float:
		aa = int(aa)
		bb = int(bb)
		stack.push_back(float(aa | bb))
	elif aa is Array and bb is Array:
		var result: Array = []
		for iota: Variant in aa:
			if not iota in result:
				result.push_back(iota)
		for iota: Variant in bb:
			if not iota in result:
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

static var exclusion_distillation_descs: Array = [
	"Given two booleans, returns True if exactly one is True, otherwise False.",
	"Given two numbers, returns a number containing every bit that is 'on' in exactly one of the numbers. Ignores decimal part of inputs.",
	"Given two lists, returns a list containing every unique element that exists in exactly ONE of the lists."
]
# Returns True if exactly one of the arguments is true; otherwise returns False.
# With two numbers, combines them into a bitset containing every "on" bit present in exactly one of the bitsets.
# With two lists, this creates a SET with every unique element that appears in exactly ONE of the lists.
# (XOR)
static func exclusion_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	var bb: Variant = stack.pop_back()
	if aa is bool and bb is bool:
		stack.push_back(aa != bb)
	elif aa is float and bb is float:
		aa = int(aa)
		bb = int(bb)
		stack.push_back(float(aa ^ bb))
	elif aa is Array and bb is Array:
		var result: Array = []
		for iota: Variant in aa:
			if (not iota in bb) and (not iota in result):
				result.push_back(iota)
		for iota: Variant in bb:
			if (not iota in aa) and (not iota in result):
				result.push_back(iota)
		stack.push_back(result)
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_PAIR, pattern.name_display, aa, bb))
		return false
	return true

# ----- Entities -----

static var entity_purification_descs: Array = [
	"Given a vector, returns the entity at that position vector, or null if no entity is found. Must exactly match entity position.",
]
# Take a position, then return the first entity at that position
static func entity_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var entities: Array = hexecutor.level_base.entities
	for entity: Entity in entities:
		if entity.get_pos().x == pos.x and entity.get_pos().y == pos.y:
			stack.push_back(entity)
			hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
			return true
	stack.push_back(null) # If no entity found
	return true

static var zone_distillation_descs: Array = [
	"Given a position (SECOND) and a distance (TOP), returns a list of all entities within that distance of the position.",
	"The list is sorted by distance, with the closest entity being the first element. Distance from position is capped at 5 tiles.",
]
# Take a position (second-top) and max distance (top), then combine them into a list of all entities near the position.
# Result is sorted by distance, closest entity (The caster normally) being index 0.
# Max distance is capped at 5 tiles. (Prevent getting every entity on map) Position can be any distance away.
static func zone_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var dst: Variant = stack.pop_back()
	if not dst is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", dst))
		return false
	if dst < 0 or dst > 5:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, 5, dst))
		return false
	dst = Entity.FAKE_SCALE * dst # Convert to real distance
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "vector", pos))
		return false
	pos = Entity.fake_to_real(pos) # Convert to real position
	var entities: Array = hexecutor.level_base.entities
	var result_unsorted: Array = []
	for entity: Entity in entities:
		var dist: float = (entity.get_pos() - pos).length()
		if dist <= dst:
			result_unsorted.append([entity, dist])
	stack.push_back(zone_dist_sort(result_unsorted))
	hexecutor.caster.node.particle_target(pos) # Particles
	return true
# Takes a result_unsorted list and returns a list of just sorted entities
# Sort determines which entity is further, using the second element of the list.
static func zone_dist_sort(unsorted: Array) -> Array:
	unsorted.sort_custom(func(aa: Array, bb: Array) -> Array: return aa[1] < bb[1])
	return unsorted.map(func(item: Array) -> Array: return item[0])

# ----- List Manipulation -----

static var integration_distillation_descs: Array = [
	"Given an iota (TOP) and a list (SECOND), returns the list with the iota appended to the end.",
]
# Remove the top of the stack, then add it to the end of the list at the top of the stack.
static func integration_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", list))
		return false
	list.push_back(iota)
	stack.push_back(list)
	return true

static var derivation_decomposition_descs: Array = [
	"Given a list, removes the last iota and returns the list and iota to the stack, with the iota above the list.",
]
# Remove the iota on the end of the list at the top of the stack, and add it to the top of the stack.
static func derivation_decomposition_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var iota: Variant = list.pop_back()
	stack.push_back(list)
	stack.push_back(iota)
	return true

static var speakers_distillation_descs: Array = [
	"Given an iota (TOP) and a list (SECOND), append the iota to the start of the list and return the result.",
]
# Remove the top iota, then add it as the first element to the list at the top of the stack.
static func speakers_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", list))
		return false
	list.push_front(iota)
	stack.push_back(list)
	return true

static var speakers_decomposition_descs: Array = [
	"Given a list, removes the first iota from it and returns the iota and the resulting list to the stack. Iota above list.",
]
# Remove the first iota from the list at the top of the stack, then push that iota to the stack.
static func speakers_decomposition_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var iota: Variant = list.pop_front()
	stack.push_back(list)
	stack.push_back(iota)
	return true

static var vacant_reflection_descs: Array = [
	"Returns an empty list.",
]
# Push an empty list to the top of the stack.
static func vacant_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back([])
	return true

static var selection_distillation_descs: Array = [
	"Given a number (TOP) and a list (SECOND), returns the num-th element of the list. If the number is out of bounds, returns null. (0-indexed)",
]
# Remove the number (num) at the top of the stack, then replace the list at the top with the num-th element of that list.
# Replaces the list with Null if the number is out of bounds.
static func selection_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	num = int(num) # Just in case
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", list))
		return false
	if num < 0 or num >= len(list):
		stack.push_back(null)
	else:
		stack.push_back(list[num])
	return true

static var selection_exaltation_descs: Array = [
	"Given two numbers (TOP, SECOND) and a list (THIRD), returns a sublist from the list between the two numbers. Details next desc.",
	"Lower bound (SECOND) inclusive, upper bound (TOP) exclusive. If TOP is less than SECOND, returns [].",
]
# Remove the two numbers at the top of the stack, then take a sublist of the list at the top of the stack between those indices.
# Lower bound inclusive, upper bound exclusive. For example, the 0, 2 sublist of [0, 1, 2, 3, 4] would be [0, 1].
# The top iota, num2, is the upper bound.
# Nums must be in range, though can be ordered backwards to return [].
static func selection_exaltation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num2: Variant = stack.pop_back()
	if not num2 is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num2))
		return false
	num2 = int(num2) # Just in case
	var num1: Variant = stack.pop_back()
	if not num1 is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", num1))
		return false
	num1 = int(num1)
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 2, "list", list))
		return false
	# Ensure nums within bounds
	if num1 < 0 or num1 >= list.size(): # Lower bound (inclusive)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 1, 0, list.size() - 1, num1))
		return false
	if num2 < 0 or num2 > list.size(): # Upper bound (exclusive)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, list.size(), num2))
		return false
	# Push the sublist
	var sublist: Array = list.slice(num1, num2)
	stack.push_back(sublist)
	return true

static var locators_distillation_descs: Array = [
	"Given an iota (TOP) and a list (SECOND), returns the index of the first instance of that iota in the list. If not found, returns -1. (0-indexed).",
]
# Remove the top iota, then replace the list at the top with the first index of that iota within the list (starting from 0).
# Replaces the list with -1 if the iota doesn't exist in the list.
static func locators_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", list))
		return false
	var index: int = -1
	for ii in range(list.size()):
		if iota is Pattern: # Special case (!!! Later, put the if on the outside of the for, so we have two for loops but the if is checked once only.)
			if list[ii] is Pattern and list[ii].name_internal == iota.name_internal:
				index = ii
				break
		else:
			if list[ii] == iota:
				index = ii
				break
	stack.push_back(float(index))
	return true

static var flocks_gambit_descs: Array = [
	"Given a number, removes that many iotas after the number and returns a list of the removed iotas. The first (TOP) iota removed (Not the initial num) will be the last item in the list.",
]
# Removes num (iota) elements from the stack, then creates a new list with the removed elements.
static func flocks_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	if num < 0 or num > stack.size():
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, stack.size(), num))
		return false
	var new_list: Array = []
	for ii in range(num):
		new_list.push_front(stack.pop_back()) # push_front so that first iota popped is last in list (Match hexcasting)
	stack.push_back(new_list)
	return true

static var flocks_disintegration_descs: Array = [
	"Given a list, returns its contents to the stack. The last element in the list will be at the top of the stack.",
]
# Remove the list at the top of the stack, then push its contents to the stack.
static func flocks_disintegration_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	for ii: Variant in list:
		stack.push_back(ii)
	return true

static var excisors_distillation_descs: Array = [
	"Given a number (TOP) and a list (SECOND), removes the num-th element of the list and returns the new list. (0-indexed)",
]
# Remove the number (num) at the top of the stack, then remove the num-th element of the list at the top of the stack
# Does nothing if the number is out of bounds
static func excisors_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", list))
		return false
	if num > 0 and num < list.size():
		list.pop_at(num) # Only pop if in range
	stack.push_back(list)
	return true

static var surgeons_exaltation_descs: Array = [
	"Given an iota (TOP), a number (SECOND) and a list (THIRD), sets the number-th element of the list to the given iota and returns the list. Iota is lost if number is out of bounds.",
]
# Remove the top iota (iota) then a number (num), then set the num-th element of the top list to that iota.
# Does nothing if the number is out of bounds.
static func surgeons_exaltation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", num))
		return false
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 2, "list", list))
		return false
	if num > 0 or num < list.size():
		list[num] = iota
	stack.push_back(list)
	return true

static var retrograde_purification_descs: Array = [
	"Given a list, returns a new list with the elements in reverse order.",
]
# Reverse the list at the top of the stack.
static func retrograde_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	list.reverse()
	stack.push_back(list)
	return true

static var singles_purification_descs: Array = [
	"Removes the top iota, then returns a list containing only that iota.",
]
# Remove the top iota, then push a list containing only that iota.
static func singles_purification_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	stack.push_back([iota])
	return true

# ----- Escaping Patterns -----

static var consideration_descs: Array = [
	"After casting, the next pattern cast will be added to the stack as an iota rather than being executed.",
]
# Enables consideration mode.
static func consideration_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.consideration_mode = true
	return true

static var introspection_descs: Array = [
	"Begins creating a list of pattern iotas. Until Retrospection is cast, future patterns are appended to this list as iotas rather than being executed.",
]
# Adds a new empty pattern_metalist to the stack, then enables introspection mode.
static func introspection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Pattern_Metalist.new())
	hexecutor.introspection_depth += 1
	return true

static var retrospection_descs: Array = [
	"Completes an introspection and stops saving future patterns as iotas. Does not end introspection if more than one introspection is active.",
]
# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding. 
# (This pattern is used to exit a layer of introspection normally)
static func retrospection_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.HASTY_RETROSPECTION, pattern.name_display))
	return false

static var evanition_descs: Array = [
	"Removes a single pattern from the metalist of patterns being drawn, or removes the metalist if it is empty. No effect if not in introspection mode.",
]
# As this is a special pattern, it should never actually be executed.
# If it is, either the player sucks at hexcasting or I suck at coding.
# (This pattern removes a pattern iota from a metalist normally, does nothing outside of introspection)
static func evanition_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.BAD_EVANITION, pattern.name_display))
	return false

# ----- Reading and Writing -----

static var scribes_reflection_descs: Array = [
	"Copies the iota stored in the caster's selected spellbook page and adds it to the stack.",
]
# Copy the iota stored in the caster's selected spellbook page and add it to the stack.
static func scribes_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var iota: Variant = hexecutor.caster.node.get_iota()
	if iota is Array:
		hexecutor.stack.push_back(iota.duplicate(true)) # Deep copy
	else:
		hexecutor.stack.push_back(iota)
	return true

static var scribes_gambit_descs: Array = [
	"Removes the top iota from the stack, and saves it into the caster's selected spellbook page.",
]
# Remove the top iota from the stack, and save it into the caster's selected spellbook page.
static func scribes_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	var player: Player = hexecutor.caster.node
	hexecutor.log_spellbook_change(player.sb_sel) # Spellbook item is changed
	player.set_iota(hexecutor.stack.pop_back())
	return true

static var chroniclers_purification_descs: Array = [
	"Given an entity iota, returns a copy of the iota contained in the entity. If the entity isn't readable for any reason, returns null.",
	"If given a player entity, the iota is copied from the player's selected spellbook page"
]
# Remove an entity iota, and pushes the entity's iota. (Or entity's spellbook selected iota)
# Always returns <null> if the entity can't be read from externally.
static func chroniclers_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false
	stack.push_back(entity.get_iota())
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true

static var chroniclers_gambit_descs: Array = [
	"Given an entity (SECOND) and an iota (TOP), stores the iota in the given entity. If the entity can't hold iotas, then it is lost.",
	"If given a player entity, the iota is stored in the player's selected spellbook page."
]
# Remove the top iota from the stack, then an entity, and save the iota to the entity. (Or entity's selected spellbook page.)
# Fails silently if the entity can't be written to externally.
static func chroniclers_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var iota: Variant = stack.pop_back()
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "entity", entity))
		return false
	entity.set_iota(iota)
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true

static var auditors_purification_descs: Array = [
	"Returns true if the given entity's spellbook can be read from externally, false otherwise.",
]
# Push true if the specified entity's spellbook can be read from externally, false otherwise.
static func auditors_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false
	stack.push_back(entity.readable)
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true

static var assessors_purification_descs: Array = [
	"Returns true if the given entity's spellbook can be written to externally, false otherwise.",
]
# Push true if the specified entity's spellbook can be written to externally, false otherwise.
static func assessors_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false
	stack.push_back(entity.writeable)
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true

static var huginns_gambit_descs: Array = [
	"Removes the top iota from the stack, and saves it to the caster's ravenmind.",
]
# Removes the top iota from the stack, and saves it to the caster's ravenmind.
static func huginns_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.log_spellbook_change(9) # Ravenmind is changed
	hexecutor.caster.node.ravenmind = hexecutor.stack.pop_back()
	return true

static var muninns_reflection_descs: Array = [
	"Returns a copy of the iota stored in the caster's ravenmind.",
]
# Copy the iota out of the caster's ravenmind.
static func muninns_reflection_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.stack.push_back(hexecutor.caster.node.ravenmind)
	return true

# ----- Advanced Mathematics -----

static var cosine_purification_descs: Array = [
	"Given a number, returns the COSINE of that number in radians.",
]
# Takes the cosine of an angle in radians, yielding the horizontal component of that angle drawn on a unit circle.
static func cosine_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(cos(num))
	return true
	
static var sine_purification_descs: Array = [
	"Given a number, returns the SINE of that number in radians.",
]
# Takes the sine of an angle in radians, yielding the vertical component of that angle drawn on a unit circle.
static func sine_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(sin(num))
	return true
	
static var tangent_purification_descs: Array = [
	"Given a number, returns the TANGENT of that number in radians.",
]
# Takes the tangent of an angle in radians, yielding the slope of that angle drawn on a circle.
static func tangent_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(tan(num))
	return true
	
static var inverse_cosine_purification_descs: Array = [
	"Given a number, returns the INVERSE COSINE of that number in radians.",
]
# Takes the inverse cosine of a value with absolute value 1 or less, yielding the angle whose cosine is that value.
static func inverse_cosine_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(acos(num))
	return true
	
static var inverse_sine_purification_descs: Array = [
	"Given a number, returns the INVERSE SINE of that number in radians.",
]
# Takes the inverse sine of a value with absolute value 1 or less, yielding the angle whose sine is that value.
static func inverse_sine_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(asin(num))
	return true
	
static var inverse_tangent_purification_descs: Array = [
	"Given a number, returns the INVERSE TANGENT of that number in radians.",
]
# Takes the inverse tangent of a value, yielding the angle whose tangent is that value.
static func inverse_tangent_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	stack.push_back(atan(num))
	return true
	
static var inverse_tangent_purification_ii_descs: Array = [
	"Given two numbers X (SECOND) and Y (TOP), returns the angle between the X-axis and a line from the origin to that point.",
]
# Takes the inverse tangent of a Y (aa) and X (bb) value,
# Yielding the angle between the X-axis and a line from the origin to that point. (!!! Should this be a vector?)
static func inverse_tangent_purification_ii_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	var result: float = atan2(aa, bb)
	stack.push_back(result)
	return true
	
static var logarithmic_distillation_descs: Array = [
	"Given two numbers, returns the logarithm of the SECOND number using the TOP number as the base.",
]
# Removes the top number (aa), then takes the logarithm of the next number (bb) using 'aa' as its base.
static func logarithmic_distillation_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var aa: Variant = stack.pop_back()
	if not aa is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", aa))
		return false
	var bb: Variant = stack.pop_back()
	if not bb is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "number", bb))
		return false
	stack.push_back(log(bb) / log(aa))
	return true

# ----- Sets -----

static var uniqueness_purification_descs: Array = [
	"Given a list, returns a new list with all duplicate entries removed.",
]
# Removes duplicate entries from a list.
static func uniqueness_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var new_list: Array = []
	for iota: Variant in list:
		if not iota in new_list:
			new_list.push_back(iota)
	stack.push_back(new_list)
	return true

# ----- Meta-Evaluation -----

static var hermes_gambit_descs: Array = [
	"Given a pattern or list of patterns, will cast them in order as if they were casted manually. Max depth is 128.",
]
# Remove a pattern or list of patterns from the stack, then cast them.
# Max depth 128.
static func hermes_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if list is Pattern: # Turn single pattern into list
		list = [list]
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "pattern/list", list))
		return false
	for ii in range(list.size()):
		if not list[ii] is Pattern:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name_display, 0, "pattern", ii, list[ii]))
			return false
	hexecutor.execution_depth += 1 # Prevent infinite recursion
	for next_pattern: Pattern in list:
		var success: bool = hexecutor.execute_pattern(next_pattern, false) # False means don't update display on pattern success
		if hexecutor.charon_mode:
			hexecutor.charon_mode = false
			hexecutor.execution_depth -= 1
			return true # Stop execution
		if not success:
			hexecutor.execution_depth -= 1
			return false # End early
	hexecutor.execution_depth -= 1
	return true

static var charons_gambit_descs: Array = [
	"When cast, this pattern ends any meta-execution, decrementing the execution depth by one. If cast manually (Outside of Hermes etc.), it will simply end the current hex.",
]
# Exit the current meta-pattern. Said meta-pattern should set charon_mode to false on exit.
# If not in a meta-pattern, simply end the current hex (Clear grid and stack etc)
static func charons_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.charon_mode = true
	return true

static var thoths_gambit_descs: Array = [
	"Given a list of iotas (TOP) and a list of PATTERNS (SECOND), will execute the patterns over each element of TOP. Specifics next desc.",
	"For EACH element in TOP, will copy the initial stack and add the element to the top, then executes each pattern in SECOND on the new stack. The iotas left in the stack afterward are saved to a list, and the list is pushed to the main stack once all elements have been used.",
	"Order of saving stack results to return list is tip to tail, with bottom of stack from first iota (TOP[0]) being the first element in the return list.",
	"This is your 'foreach' loop. Use it well."
]
# Remove a list of patterns (bb) and a list (aa) from the stack, then cast the given pattern over each element of the second list.
# More specifically, for each element in the second list, it will:
# - Create a new stack, with everything on the current stack plus that element
# - Draw all the patterns in the first list
# - Save all the iotas remaining on the stack to a list
# Then, after all is said and done, pushes the list of saved iotas onto the main stack.
# Order of saving to results list is tip to tail, with bottom of first (first = list[0] iota) stack being the first element.
static func thoths_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var patterns: Variant = stack.pop_back()
	if not patterns is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "list", patterns))
		return false
	for ii in range(patterns.size()):
		if not patterns[ii] is Pattern:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name_display, 0, "pattern", ii, patterns[ii]))
			return false
	
	hexecutor.execution_depth += 1 # Prevent infinite recursion (!!! Should this be 8 or smth to reduce recursion for thoths?)
	var results: Array = [] # List of results from each list iota. 
	var hexecutor2: Hexecutor = Hexecutor.new(hexecutor.level_base, hexecutor.caster, hexecutor.main_scene, false) # New hexecutor for meta execution (New stack)
	# Note this hexecutor takes "false" as a fourth argument, which among other things means it will not update the display.
	hexecutor2.execution_depth = hexecutor.execution_depth # Execution depth persist to prevent infinite recursion

	for iota: Variant in list:
		hexecutor2.stack = stack.duplicate(true) # Copy stack (Deep copy)
		hexecutor2.stack.push_back(iota) # Load 
		for next_pattern: Pattern in patterns:
			var success: bool = hexecutor2.execute_pattern(next_pattern, false) # False means don't update display on pattern success
			if hexecutor2.charon_mode or not success:
				# Leave charon mode set true, as we won't be returning to this hexecutor anyway. Safer to leave true.
				break # Stop executing patterns for this iota
		
		results.append_array(hexecutor2.stack) # Append leftover stack to results
		hexecutor2.reset(true) # Clean up, don't reset ravenmind
		if hexecutor2.charon_mode:
			break # Don't execute any more list iotas

	# Note to self, execution depth should be equal at this point, so copying it is redundant. (That's the idea anyway.)
	hexecutor.execution_depth -= 1

	# Copy over change trackers from hexecutor2
	hexecutor.tracker_sb_selected_changed = hexecutor2.tracker_sb_selected_changed or hexecutor.tracker_sb_selected_changed # Just set true if either has changed it.
	hexecutor.log_spellbook_change(hexecutor2.tracker_sb_item_changed) # Copy over spellbook changes

	stack.push_back(results) # Push results
	return true

# ----- Addons -----

# Hexal Math

static var factorial_purification_descs: Array = [
	"Given a number, returns the factorial of that number. For example, 4 would return 4*3*2*1=24.",
	"Of note: Inputs larger than 21 will be inaccurate due to floating point precision. Decimal value of any input is ignored."
]
# Takes a number from the stack and computes its factorial, for example inputting 4 would return 4*3*2*1=24.
# WARNING: Inputs larger than 21 will be inaccurate due to floating point precision.
# Also worth noting that decimal point will be removed, so 4.5 will be treated as 4.
static func factorial_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	var numi: float = int(num) # Round down. Result will still be float due to "if num <= 0, return 1.0" code
	if numi < 0 or numi > 50: # 22 is inaccurate, 50 is the max. (Please stop)
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, 50, numi))
		return false
	stack.push_back(factorial(numi))
	return true
# Factorial helper (Recursive)
static func factorial(num: float) -> float:
	if num <= 0:
		return 1.0
	return num * factorial(num - 1)

static var running_sum_purification_descs: Array = [
	"Given a list of numbers, returns a list of numbers where each element is the SUM of all the elements before it. Example: [1,2,5] would return [1,3,8].",
]
# Takes a list from the stack and computes its running sum, for example inputting [1,2,5] would return [1,3,8].
static func running_sum_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var sum: float = 0
	var new_list: Array = []
	for ii: Variant in list:
		if not ii is float:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name_display, 0, "float", new_list.size(), ii))
			return false
		sum += ii
		new_list.append(sum)
	stack.push_back(new_list)
	return true

static var running_product_purification_descs: Array = [
	"Given a list of numbers, returns a list of numbers where each element is the PRODUCT of all the elements before it. Example: [1,2,5] would return [1,2,10].",
]
# Takes a list from the stack and computes its running product, for example inputting [1,2,5] would return [1,2,10].
static func running_product_purification_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var list: Variant = stack.pop_back()
	if not list is Array:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "list", list))
		return false
	var sum: float = 1
	var new_list: Array = []
	for ii: Variant in list:
		if not ii is float:
			stack.push_back(Bad_Iota.new(ErrorMM.LIST_CONTAINS_INVALID, pattern.name_display, 0, "float", new_list.size(), ii))
			return false
		sum *= ii
		new_list.append(sum)
	stack.push_back(new_list)
	return true

# ----- Level Access -----

static var enter_descs: Array = [
	"Given an entity that contains a level, will cause the caster to enter that level, leaving behind any stack and spellbook iotas for when they return.",
]
# Upon casting, this pattern will cause the caster to enter the level given by the supplied level_haver
static func enter_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false
	if not entity.node is Level_Haver:
		stack.push_back(Bad_Iota.new(ErrorMM.NOT_LEVEL_HAVER, pattern.name_display))
		return false
	hexecutor.caster.node.particle_cast(0) # Play success particles before entering. Hexecutor will play more when inside level, but not on current level.
	hexecutor.caster.node.particle_clear_targets() # Clear targeting particles, to prevent weird effects when returning to the level.
	hexecutor.main_scene.save_then_load_level(entity.node) # Level_haver is sent so it can be saved and updated later.
	hexecutor.scram_mode = true # Stop executing patterns
	return true

static var exit_descs: Array = [
	"Cast this spell to exit a level. Requires the caster as an argument to prevent accidental use.",
]
# Upon casting, this pattern will cause the caster to unload and exit the level.
# Returns Bad_Iota if there is no level to exit to.
# Takes the caster as an iota, to help prevent accidental use.
static func exit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var caster: Variant = stack.pop_back()
	if not caster is Entity or caster != hexecutor.caster:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity (player)", caster))
		return false
	hexecutor.main_scene.exit_level()
	hexecutor.scram_mode = true # Stop executing patterns
	# No particles because they won't be seen anyway
	return true

# ----- Spellbook -----

static var versos_gambit_descs: Array = [
	"Decrements the caster's selected spellbook page.",
]
# Decrements the caster's selected spellbook page.
static func versos_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.tracker_sb_selected_changed = true # sb selection is changed
	hexecutor.caster.node.dec_sb()
	return true

static var rectos_gambit_descs: Array = [
	"Increments the caster's selected spellbook page.",
]
# Increments the caster's selected spellbook page.
static func rectos_gambit_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.tracker_sb_selected_changed = true # sb selection is changed
	hexecutor.caster.node.inc_sb() 
	return true

static var tomes_gambit_descs: Array = [
	"Given a number, sets the caster's selected spellbook page to that number.",
]
# Sets the caster's selected spellbook page to num (top of stack)
static func tomes_gambit_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.tracker_sb_selected_changed = true # sb selection is changed
	var stack: Array = hexecutor.stack
	var num: Variant = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", num))
		return false
	var player: Player = hexecutor.caster.node
	var size: int = player.sb.size() # Should be 9 always, but just in case I change it later.
	if num < 0 or num >= size:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 0, size-1, num))
		return false
	player.sb_sel = int(num)
	return true

# ----- Spells -----

# Sentinel

static var summon_sentinel_descs: Array = [
	"Given a position, moves the caster's sentinel to that position. Creates a sentinel if one doesn't exist.",
]
# Summons/Moves the caster's sentinel to the given position
static func summon_sentinel_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	hexecutor.log_spellbook_change(10) # Sentinel is changed
	var stack: Array = hexecutor.stack
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", pos))
		return false
	hexecutor.caster.node.set_sentinel(pos)
	hexecutor.caster.node.particle_target(Entity.fake_to_real(pos)) # Particles
	return true

static var banish_sentinel_descs: Array = [
	"Removes the caster's sentinel.",
]
# Removes the caster's sentinel.
static func banish_sentinel_exe(hexecutor: Hexecutor, _pattern: Pattern) -> bool:
	hexecutor.log_spellbook_change(10) # Sentinel is changed
	var player: Player = hexecutor.caster.node
	if player.sentinel_pos != null: # No extra particles if no sentinel
		player.particle_target(Entity.fake_to_real(player.sentinel_pos)) # Particles
	player.set_sentinel(null)
	return true

static var locate_sentinel_descs: Array = [
	"Returns the caster's sentinel position. Fails if the caster has no sentinel.",
]
# Pushes the caster's sentinel position onto the stack
static func locate_sentinel_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var sentinel_pos: Variant = hexecutor.caster.node.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_SENTINEL, pattern.name_display))
		return false
	stack.push_back(sentinel_pos)
	hexecutor.caster.node.particle_target(Entity.fake_to_real(sentinel_pos)) # Particles
	return true

static var wayfind_sentinel_descs: Array = [
	"Given a position, returns a vector from the position to the caster's sentinel. Fails if sentinel does not exist.",
]
# Takes a position, then returns a vector from the position to the caster's sentinel.
static func wayfind_sentinel_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var sentinel_pos: Variant = hexecutor.caster.node.sentinel_pos
	if sentinel_pos == null:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_SENTINEL, pattern.name_display))
		return false
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", pos))
		return false
	var result: Vector2 = sentinel_pos - pos
	stack.push_back(result)
	hexecutor.caster.node.particle_target(Entity.fake_to_real(sentinel_pos)) # Particles
	hexecutor.caster.node.particle_trail(Entity.fake_to_real(pos), Entity.fake_to_real(result)) # Trail
	return true

# Other

static var explosion_descs: Array = [
	"Given a position (SECOND) and a size (TOP), deletes all entities within 'size' tiles of the position (Square shape).",
	"Minimum size is 1, meaning an entity neighbouring the position will always be deleted. This spell fails if player is in range."
]
# Takes a position (b) and a size (a), then deletes all entities within "size" tiles of the position (Square shape)
# Position is rounded to centre on tile. Size can not be less than 1 (Will kill at least the neighbours)
static func explosion_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var size: Variant = stack.pop_back()
	if not size is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "number", size))
		return false
	if size < 1:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, 1, "any", size))
		return false
	var pos: Variant = stack.pop_back()
	if not pos is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "vector", pos))
		return false
	pos = pos.round() # Round to centre on tile and prevent cheese (No edge sniping single targets in group)
	var level_base: Level_Base = hexecutor.level_base
	var entities: Array = level_base.entities
	var close_entities: Array = []
	for entity: Entity in entities:
		var entity_pos: Vector2 = entity.get_fake_pos() # pos and radius are in fake/tile space
		var distance: Vector2 = abs(entity_pos - pos) 
		if distance.x <= size and distance.y <= size:
			close_entities.push_back(entity)
	if hexecutor.caster in close_entities: # Error if caster is in explosion radius (Even though it wouldn't be removed)
		stack.push_back(Bad_Iota.new(ErrorMM.CASTER_IN_RANGE, pattern.name_display))
		return false
	for entity: Entity in close_entities:
		level_base.remove_entity(entity) # Will not remove unkillable entities
	hexecutor.caster.node.particle_target(Entity.fake_to_real(pos)) # Particles
	return true

static var impulse_descs: Array = [
	"Given an entity (SECOND) and a vector (TOP), pushes the entity in the given direction by the vector magnitude.",
	"Must be a moveable entity. Max magnitude is 16. Entities that aren't levitating will collide with spikes and die."
]
# Takes an entity (b) and a vector (a), then pushes the entity in the given direction by the vector magnitude. (Max magnitude is 16)
# If entity is levitating, does NOT collide with spikes.
static func impulse_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var vector: Variant = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", vector))
		return false
	var length: float = vector.length()
	if length > 16:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name_display, 0, "length 0", "length 16", "length " + str(length)))
		return false
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "entity", entity))
		return false
	if (not entity.moveable) or (length < 0.1): # If can't move entity, or distance is ~0, just return silently
		return true
	var pos_real: Vector2 = entity.get_pos() # Actual pos (For raycasting)
	var pos: Vector2 = Entity.real_to_fake(pos_real) # Fake pos (For interpolation)
	var level_base: Level_Base = hexecutor.level_base # Used to do raycasting
	var target: Vector2 = level_base.impulse_raycast(pos_real, vector * Entity.FAKE_SCALE, entity.is_levitating) # Return point of tile hit (or max dist)
	var interpolated: Array = impulse_interpolated_line(pos, target) # Slightly short
	for tile: Vector2 in interpolated: # Should start at furthest tile and work backwards, due to order of list.
		if level_base.entity_at(tile): # Entity check (The actually important check)
			continue 
		if (not entity.is_levitating) and level_base.get_tile_id(tile, 1) == 21: # Spike check
			var dead: bool = level_base.remove_entity(entity) # Attempt to push poor entity into spikes
			if dead:
				return true # Woo
			else:
				continue # Player can't be killed, so keep looking for safe spot.
		var tile_id: int = level_base.get_tile_id(tile, 0)
		if tile_id == 1 or tile_id == 2: # Wall/Glass check
			continue # Can't land here, nope.
		if tile_id == 0: # Out of Bounds check (Regardless of is_levitating)
			if level_base.remove_entity(entity): # Attempt to push poor entity out of map
				return true # Woo
			# Else, if not dead, still set pos. See what happens. (Likely the player, and will respawn)
		var old_pos: Vector2 = entity.get_pos() # REAL coords, used for particles
		entity.set_fake_pos(tile)
		entity.is_levitating = false # Clear levitating status (Irrelevant if entity is not levitating)
		hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
		hexecutor.caster.node.particle_trail(old_pos, Entity.fake_to_real(vector)) # Old pos to desired location, NOT current location.
		return true
	entity.is_levitating = false # Still clear levitating status
	return true # Just don't impulse
# Returns a set of points from p1 to p0 using linear interpolation
static func impulse_interpolated_line(p0: Vector2, p1: Vector2) -> Array:
	var points: Array = []
	var dp: Vector2 = p1 - p0
	var l_dist: int = roundi(max(abs(dp.x), abs(dp.y)))
	if l_dist == 0:
		return [] # Prevent returning (nan, nan) points and sending entity to shadow realm
	for ii in l_dist + 1: 
		var tt: float = float(ii) / l_dist
		points.append(lerp(p1, p0, tt).round())
	return points

static var levitate_descs: Array = [
	"Toggles levitating status on a moveable entity. This allows them to be moved over hazards, though only once.",
	"Additionally, allows players to fly, and gives them ice physics."
]
# Takes an entity, then gives them levitating for their next impulse. Will remove levitating if they already have it.
# Also allows player entities to fly.
static func levitate_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "entity", entity))
		return false
	if entity.is_levitating:
		entity.is_levitating = false # Remove levitating if they already have it.
	else:
		entity.is_levitating = entity.moveable # If the entity is moveable, then levitate them.
	hexecutor.caster.node.particle_target(entity.get_pos()) # Particles
	return true

static var teleport_descs: Array = [
	"Given an entity (SECOND) and a vector (TOP), teleports the entity by the given vector offset. Will fail if destination is not a gate, or the gate is blocked.",
	"Must be a moveable entity. No max distance. Can teleport through glass, but not through walls."
]
# Takes an entity (b) and a vector (a), then teleports the entity by the vector if the destination is an unblocked gate.
# This pattern can teleport through glass, but not through walls.
static func teleport_exe(hexecutor: Hexecutor, pattern: Pattern) -> bool:
	var stack: Array = hexecutor.stack
	var vector: Variant = stack.pop_back()
	if not vector is Vector2:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 0, "vector", vector))
		return false
	var entity: Variant = stack.pop_back()
	if not entity is Entity:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name_display, 1, "entity", entity))
		return false
	var pos: Vector2 = entity.get_fake_pos()
	var dest: Vector2 = round(pos + vector)
	if not entity.moveable: # If can't move entity, just return silently
		return teleport_finish(true, hexecutor, pos, vector, dest)
	var level_base: Level_Base = hexecutor.level_base # For functions
	if hexecutor.level_base.get_tile_id(dest, 1) == 22: # If gate
		if not level_base.entity_at(dest): # If no entity
			# Ensure line of sight
			# (Unnormalized vector + false value, which will create shorter raycasts. (Equal to vector length))
			var hit: Variant = level_base.block_raycast(pos * Entity.FAKE_SCALE, vector * Entity.FAKE_SCALE, false)
			if hit == null: # No blocks in way
				entity.set_fake_pos(dest)
		# No error if gate is blocked or not in sight, should be visually obvious anyway.
	else:
		stack.push_back(Bad_Iota.new(ErrorMM.NO_GATE, pattern.name_display, vector, dest)) # DO error here, since it's less obvious. If your thoth is missing the gate, you'll want to know.
		return teleport_finish(false, hexecutor, pos, vector, dest)
	return teleport_finish(true, hexecutor, pos, vector, dest)
# Teleport can end early at multiple points, but I want particles to always show. Thus this function cuts back on repeated particle code.
static func teleport_finish(success: bool, hexecutor: Hexecutor, old_pos: Vector2, vector: Vector2, dest: Vector2) -> bool:
	hexecutor.caster.node.particle_trail(Entity.fake_to_real(old_pos), Entity.fake_to_real(vector)) # Show attempted teleport regardless of tp success
	hexecutor.caster.node.particle_target(Entity.fake_to_real(dest)) # Poof at destination, again regardless of gate.
	return success

# ---------------------- Static Pattern Dictionary ---------------------- #

# Dictionary of static patterns.
# Key is the raw_code value, which excludes p_code's initial number (Rotation is irrelevant)
# Order of value array is as so:
#   0: Internal name of pattern		Pattern_Enum
#   1: Display name of pattern		String
#   2: Short name of pattern		String
#   3: Pattern is_spell value		bool
#   4: Pattern p_exe iota count		int
#   5: Pattern description list		Array(String)
#   6: Pattern p_exe function		Callable/Function
# 
# The relevant description list and functions are defined above this dictionary.
# Godot craps out when the static arrays are defined after this dictionary, thus this dictionary is defined last.
static var static_patterns: Dictionary = {
	# Basic Patterns
	"LL": [Pattern_Enum.compass_purification, "Compass' Purification", "ComPu", false, 1, compass_purification_descs, compass_purification_exe],
	"lLl": [Pattern_Enum.minds_reflection, "Mind's Reflection", "MinRe", false, 0, minds_reflection_descs, minds_reflection_exe],
	"sL": [Pattern_Enum.alidades_purification, "Alidade's Purification", "AliPu", false, 1, alidades_purification_descs, alidades_purification_exe],
	"sl": [Pattern_Enum.pace_purification, "Pace Purification", "PacPu", false, 1, pace_purification_descs, pace_purification_exe],
	"Rr": [Pattern_Enum.reveal, "Reveal", "Rev", true, 1, reveal_descs, reveal_exe],
	"slLLsRR": [Pattern_Enum.archers_distillation, "Archer's Distillation", "ArcDi", false, 2, archers_distillation_descs, archers_distillation_exe],
	"srRRsLL": [Pattern_Enum.architects_distillation, "Architect's Distillation", "ArcDi", false, 2, architects_distillation_descs, architects_distillation_exe],
	"srLlL": [Pattern_Enum.scouts_distillation, "Scout's Distillation", "ScoDi", false, 2, scouts_distillation_descs, scouts_distillation_exe],

	# Mathematics
	"slLls": [Pattern_Enum.length_purification, "Length Purification", "LenPu", false, 1, length_purification_descs, length_purification_exe],
	"sLLs": [Pattern_Enum.additive_distillation, "Additive Distillation", "AddDi", false, 2, additive_distillation_descs, additive_distillation_exe],
	"sRRs": [Pattern_Enum.subtractive_distillation, "Subtractive Distillation", "SubDi", false, 2, subtractive_distillation_descs, subtractive_distillation_exe],
	"sLlLs": [Pattern_Enum.multiplicative_distillation, "Multiplicative Distillation", "MulDi", false, 2, multiplicative_distillation_descs, multiplicative_distillation_exe],
	"sRrRs": [Pattern_Enum.division_distillation, "Division Distillation", "DivDi", false, 2, division_distillation_descs, division_distillation_exe],
	"lsr": [Pattern_Enum.ceiling_purification, "Ceiling Purification", "CeiPu", false, 1, ceiling_purification_descs, ceiling_purification_exe],
	"rsl": [Pattern_Enum.floor_purification, "Floor Purification", "FloPu", false, 1, floor_purification_descs, floor_purification_exe],
	"lllllLss": [Pattern_Enum.axial_purification, "Axial Purification", "AxiPu", false, 1, axial_purification_descs, axial_purification_exe],
	"rlllll": [Pattern_Enum.vector_distillation, "Vector Distillation", "VecDi", false, 2, vector_distillation_descs, vector_distillation_exe],
	"lrrrrr": [Pattern_Enum.vector_decomposition, "Vector Decomposition", "VecDe", false, 1, vector_decomposition_descs, vector_decomposition_exe],
	"LRRsLLR": [Pattern_Enum.modulus_distillation, "Modulus Distillation", "ModDi", false, 2, modulus_distillation_descs, modulus_distillation_exe],
	"srRrs": [Pattern_Enum.power_distillation, "Power Distillation", "PowDi", false, 2, power_distillation_descs, power_distillation_exe],
	"rlll": [Pattern_Enum.entropy_reflection, "Entropy Reflection", "EntRe", false, 0, entropy_reflection_descs, entropy_reflection_exe],

	# Constants
	"LLl": [Pattern_Enum.eulers_reflection, "Euler's Reflection", "EulRe", false, 0, eulers_reflection_descs, eulers_reflection_exe],
	"lRsRl": [Pattern_Enum.arcs_reflection, "Arc's Reflection", "ArcRe", false, 0, arcs_reflection_descs, arcs_reflection_exe],
	"rLsLr": [Pattern_Enum.circles_reflection, "Circle's Reflection", "CirRe", false, 0, circles_reflection_descs, circles_reflection_exe],
	"RrRl": [Pattern_Enum.false_reflection, "False Reflection", "FalRe", false, 0, false_reflection_descs, false_reflection_exe],
	"LlLr": [Pattern_Enum.true_reflection, "True Reflection", "TruRe", false, 0, true_reflection_descs, true_reflection_exe],
	"R": [Pattern_Enum.nullary_reflection, "Nullary Reflection", "NulRe", false, 0, nullary_reflection_descs, nullary_reflection_exe],
	"lllll": [Pattern_Enum.vector_reflection_zero, "Vector Reflection Zero", "VecZe", false, 0, vector_reflection_zero_descs, vector_reflection_zero_exe],
	"rrrrrlL": [Pattern_Enum.vector_reflection_neg_x, "Vector Reflection Neg X", "VecNX", false, 0, vector_reflection_neg_x_descs, vector_reflection_neg_x_exe],
	"lllllrL": [Pattern_Enum.vector_reflection_pos_x, "Vector Reflection Pos X", "VecPX", false, 0, vector_reflection_pos_x_descs, vector_reflection_pos_x_exe],
	"rrrrrlR": [Pattern_Enum.vector_reflection_neg_y, "Vector Reflection Neg Y", "VecNY", false, 0, vector_reflection_neg_y_descs, vector_reflection_neg_y_exe],
	"lllllrR": [Pattern_Enum.vector_reflection_pos_y, "Vector Reflection Pos Y", "VecPY", false, 0, vector_reflection_pos_y_descs, vector_reflection_pos_y_exe],

	# Stack Manipulation
	"LLRLRLLs": [Pattern_Enum.dioscuri_gambit, "Dioscuri Gambit", "DioGa", false, 2, dioscuri_gambit_descs, dioscuri_gambit_exe],
	"LLRLL": [Pattern_Enum.gemini_decomposition, "Gemini Decomposition", "GemDe", false, 1, gemini_decomposition_descs, gemini_decomposition_exe],
	"LLRLLRLL": [Pattern_Enum.gemini_gambit, "Gemini Gambit", "GemGa", false, 2, gemini_gambit_descs, gemini_gambit_exe],
	"RRLR": [Pattern_Enum.fishermans_gambit, "Fisherman's Gambit", "FisGa", false, 1, fishermans_gambit_descs, fishermans_gambit_exe],
	"LLRL": [Pattern_Enum.fishermans_gambit_ii, "Fisherman's Gambit II", "FisGa", false, 1, fishermans_gambit_ii_descs, fishermans_gambit_ii_exe],
	"LLrRR": [Pattern_Enum.prospectors_gambit, "Prospector's Gambit", "ProGa", false, 2, prospectors_gambit_descs, prospectors_gambit_exe],
	"LLrLL": [Pattern_Enum.rotation_gambit, "Rotation Gambit", "RotGa", false, 3, rotation_gambit_descs, rotation_gambit_exe],
	"RRlRR": [Pattern_Enum.rotation_gambit_ii, "Rotation Gambit II", "RotGa", false, 3, rotation_gambit_ii_descs, rotation_gambit_ii_exe],
	"lsLrLslLrLlL": [Pattern_Enum.flocks_reflection, "Flock's Reflection", "FloRe", false, 0, flocks_reflection_descs, flocks_reflection_exe],
	"LLsRR": [Pattern_Enum.jesters_gambit, "Jester's Gambit", "JesGa", false, 2, jesters_gambit_descs, jesters_gambit_exe],
	"lLLsRRr": [Pattern_Enum.swindlers_gambit, "Swindler's Gambit", "SwiGa", false, 1, swindlers_gambit_descs, swindlers_gambit_exe],
	"RRlLL": [Pattern_Enum.undertakers_gambit, "Undertaker's Gambit", "UndGa", false, 2, undertakers_gambit_descs, undertakers_gambit_exe],

	# Logical Operators
	"sRs": [Pattern_Enum.conjunction_distillation, "Conjunction Distillation", "ConDi", false, 2, conjunction_distillation_descs, conjunction_distillation_exe],
	"Ls": [Pattern_Enum.augurs_purification, "Augur's Purification", "AugPu", false, 1, augurs_purification_descs, augurs_purification_exe],
	"LR": [Pattern_Enum.equality_distillation, "Equality Distillation", "EquDi", false, 2, equality_distillation_descs, equality_distillation_exe],
	"r": [Pattern_Enum.maximus_distillation, "Maximus Distillation", "MaxDi", false, 2, maximus_distillation_descs, maximus_distillation_exe],
	"rr": [Pattern_Enum.maximus_distillation_ii, "Maximus Distillation II", "MaxDi", false, 2, maximus_distillation_ii_descs, maximus_distillation_ii_exe],
	"LsRR": [Pattern_Enum.augurs_exaltation, "Augur's Exaltation", "AugEx", false, 3, augurs_exaltation_descs, augurs_exaltation_exe],
	"l": [Pattern_Enum.minimus_distillation, "Minimus Distillation", "MinDi", false, 2, minimus_distillation_descs, minimus_distillation_exe],
	"ll": [Pattern_Enum.minimus_distillation_ii, "Minimus Distillation II", "MinDi", false, 2, minimus_distillation_ii_descs, minimus_distillation_ii_exe],
	"Rs": [Pattern_Enum.negation_purification, "Negation Purification", "NegPu", false, 1, negation_purification_descs, negation_purification_exe],
	"RL": [Pattern_Enum.inequality_distillation, "Inequality Distillation", "IneDi", false, 2, inequality_distillation_descs, inequality_distillation_exe],
	"sLs": [Pattern_Enum.disjunction_distillation, "Disjunction Distillation", "DisDi", false, 2, disjunction_distillation_descs, disjunction_distillation_exe],
	"RsL": [Pattern_Enum.exclusion_distillation, "Exclusion Distillation", "ExcDi", false, 2, exclusion_distillation_descs, exclusion_distillation_exe],
    
	# Entities
	"lllllRLlL": [Pattern_Enum.entity_purification, "Entity Purification", "EntPu", false, 1, entity_purification_descs, entity_purification_exe],
	"lllllsRrR": [Pattern_Enum.zone_distillation, "Zone Distillation", "ZonDi", false, 2, zone_distillation_descs, zone_distillation_exe],

	# List Manipulation
	"rRlRr": [Pattern_Enum.integration_distillation, "Integration Distillation", "IntDi", false, 2, integration_distillation_descs, integration_distillation_exe],
	"lLrLl": [Pattern_Enum.derivation_decomposition, "Derivation Decomposition", "DerDe", false, 1, derivation_decomposition_descs, derivation_decomposition_exe],
	"RRrsrRR": [Pattern_Enum.speakers_distillation, "Speaker's Distillation", "SpeDi", false, 2, speakers_distillation_descs, speakers_distillation_exe],
	"LLlslLL": [Pattern_Enum.speakers_decomposition, "Speaker's Decomposition", "SpeDe", false, 1, speakers_decomposition_descs, speakers_decomposition_exe],
	"llLrLLr": [Pattern_Enum.vacant_reflection, "Vacant Reflection", "VacRe", false, 0, vacant_reflection_descs, vacant_reflection_exe],
	"RrrrR": [Pattern_Enum.selection_distillation, "Selection Distillation", "SelDi", false, 2, selection_distillation_descs, selection_distillation_exe],
	"lLrLlsRrR": [Pattern_Enum.selection_exaltation, "Selection Exaltation", "SelEx", false, 3, selection_exaltation_descs, selection_exaltation_exe],
	"RrRlRr": [Pattern_Enum.locators_distillation, "Locator's Distillation", "LocDi", false, 2, locators_distillation_descs, locators_distillation_exe],
	"rsRlRsr": [Pattern_Enum.flocks_gambit, "Flock's Gambit", "FloGa", false, 1, flocks_gambit_descs, flocks_gambit_exe],
	"lsLrLsl": [Pattern_Enum.flocks_disintegration, "Flock's Disintegration", "FloDi", false, 1, flocks_disintegration_descs, flocks_disintegration_exe],
	"rRlRrsLlL": [Pattern_Enum.excisors_distillation, "Excisor's Distillation", "ExcDi", false, 2, excisors_distillation_descs, excisors_distillation_exe],
	"slLrLls": [Pattern_Enum.surgeons_exaltation, "Surgeon's Exaltation", "SurEx", false, 3, surgeons_exaltation_descs, surgeons_exaltation_exe],
	"lllLrRr": [Pattern_Enum.retrograde_purification, "Retrograde Purification", "RetPu", false, 1, retrograde_purification_descs, retrograde_purification_exe],
	"LRrrrR": [Pattern_Enum.singles_purification, "Single's Purification", "SinPu", false, 1, singles_purification_descs, singles_purification_exe],

	# Escaping Patterns
	"lllLs": [Pattern_Enum.consideration, "Consideration", "Con", false, 0, consideration_descs, consideration_exe],
	"lll": [Pattern_Enum.introspection, "Introspection", "Int", false, 0, introspection_descs, introspection_exe],
	"rrr": [Pattern_Enum.retrospection, "Retrospection", "Ret", false, 0, retrospection_descs, retrospection_exe],
	"rrrRs": [Pattern_Enum.evanition, "Evanition", "Eva", false, 0, evanition_descs, evanition_exe],

	# Reading and Writing
	"Llllll": [Pattern_Enum.scribes_reflection, "Scribe's Reflection", "ScrRe", false, 0, scribes_reflection_descs, scribes_reflection_exe],
	"Rrrrrr": [Pattern_Enum.scribes_gambit, "Scribe's Gambit", "ScrGa", false, 1, scribes_gambit_descs, scribes_gambit_exe],
	"Lllllls": [Pattern_Enum.chroniclers_purification, "Chronicler's Purification", "ChrPu", false, 1, chroniclers_purification_descs, chroniclers_purification_exe],
	"Rrrrrrs": [Pattern_Enum.chroniclers_gambit, "Chronicler's Gambit", "ChrGa", true, 2, chroniclers_gambit_descs, chroniclers_gambit_exe],
	"Llllllsr": [Pattern_Enum.auditors_purification, "Auditor's Purification", "AudPu", false, 1, auditors_purification_descs, auditors_purification_exe],
	"Rrrrrrsl": [Pattern_Enum.assessors_purification, "Assessor's Purification", "AssPu", false, 1, assessors_purification_descs, assessors_purification_exe],
	"rllsLslLLs": [Pattern_Enum.huginns_gambit, "Huginn's Gambit", "HugGa", false, 1, huginns_gambit_descs, huginns_gambit_exe],
	"lrrsRsrRRs": [Pattern_Enum.muninns_reflection, "Muninn's Reflection", "MunRe", false, 0, muninns_reflection_descs, muninns_reflection_exe],

	# Advanced Mathematics
	"lllllLR": [Pattern_Enum.cosine_purification, "Cosine Purification", "CosPu", false, 1, cosine_purification_descs, cosine_purification_exe],
	"lllllLL": [Pattern_Enum.sine_purification, "Sine Purification", "SinPu", false, 1, sine_purification_descs, sine_purification_exe],
	"slllllLRl": [Pattern_Enum.tangent_purification, "Tangent Purification", "TanPu", false, 1, tangent_purification_descs, tangent_purification_exe],
	"LRrrrrr": [Pattern_Enum.inverse_cosine_purification, "Inverse Cosine Purification", "InvCo", false, 1, inverse_cosine_purification_descs, inverse_cosine_purification_exe],
	"RRrrrrr": [Pattern_Enum.inverse_sine_purification, "Inverse Sine Purification", "InvSi", false, 1, inverse_sine_purification_descs, inverse_sine_purification_exe],
	"rLRrrrrrs": [Pattern_Enum.inverse_tangent_purification, "Inverse Tangent Purification", "InvTa", false, 1, inverse_tangent_purification_descs, inverse_tangent_purification_exe],
	"RrLRrrrrrsR": [Pattern_Enum.inverse_tangent_purification_ii, "Inverse Tangent Purification II", "InvTa", false, 1, inverse_tangent_purification_ii_descs, inverse_tangent_purification_ii_exe],
	"rlLlr": [Pattern_Enum.logarithmic_distillation, "Logarithmic Distillation", "LogDi", false, 2, logarithmic_distillation_descs, logarithmic_distillation_exe],

    # Sets (Mainly in Logical Operators now)
	"LsrLlL": [Pattern_Enum.uniqueness_purification, "Uniqueness Purification", "UniPu", false, 1, uniqueness_purification_descs, uniqueness_purification_exe],

    # Meta-Evaluation
	"RrLll": [Pattern_Enum.hermes_gambit, "Hermes' Gambit", "HerGa", true, 1, hermes_gambit_descs, hermes_gambit_exe],
	"LlRrr": [Pattern_Enum.charons_gambit, "Charon's Gambit", "ChaGa", false, 0, charons_gambit_descs, charons_gambit_exe],
	"RLRLR": [Pattern_Enum.thoths_gambit, "Thoth's Gambit", "ThoGa", true, 2, thoths_gambit_descs, thoths_gambit_exe],

    ## ADDONS ##

    # Hexal Math
	"sLsRrRsLs": [Pattern_Enum.factorial_purification, "Factorial Purification", "FacPu", false, 1, factorial_purification_descs, factorial_purification_exe],
	"LrL": [Pattern_Enum.running_sum_purification, "Running Sum Purification", "RunPu", false, 1, running_sum_purification_descs, running_sum_purification_exe],
	"lLLsLLl": [Pattern_Enum.running_product_purification, "Running Product Purification", "RunPu", false, 1, running_product_purification_descs, running_product_purification_exe],

    ### NEW PATTERNS ###

    # Level access
	"llL": [Pattern_Enum.enter, "Enter", "Ent", true, 1, enter_descs, enter_exe],
	"llR": [Pattern_Enum.exit, "Exit", "Exi", true, 1, exit_descs, exit_exe],

    # Spellbook
	"RRl": [Pattern_Enum.versos_gambit, "Verso's Gambit", "VerGa", false, 0, versos_gambit_descs, versos_gambit_exe],
	"RRs": [Pattern_Enum.rectos_gambit, "Recto's Gambit", "RecGa", false, 0, rectos_gambit_descs, rectos_gambit_exe],
	"RRr": [Pattern_Enum.tomes_gambit, "Tome's Gambit", "TomGa", false, 1, tomes_gambit_descs, tomes_gambit_exe],

    ## SPELLS ##

    # Sentinel (Not really a spell, in terms of is_spell)
	"sLrLsLr": [Pattern_Enum.summon_sentinel, "Summon Sentinel", "SumSe", false, 1, summon_sentinel_descs, summon_sentinel_exe],
	"lRsRlRs": [Pattern_Enum.banish_sentinel, "Banish Sentinel", "BanSe", false, 0, banish_sentinel_descs, banish_sentinel_exe],
	"sLrLsLrRr": [Pattern_Enum.locate_sentinel, "Locate Sentinel", "LocSe", false, 0, locate_sentinel_descs, locate_sentinel_exe],
	"sLrLsLrRsL": [Pattern_Enum.wayfind_sentinel, "Wayfind Sentinel", "WaySe", false, 1, wayfind_sentinel_descs, wayfind_sentinel_exe],

    # Other
	"LLsLLsLL": [Pattern_Enum.explosion, "Explosion", "Exp", true, 2, explosion_descs, explosion_exe],
	"LslllsLls": [Pattern_Enum.impulse, "Impulse", "Imp", true, 2, impulse_descs, impulse_exe],
	"lllllLssLsLsR": [Pattern_Enum.levitate, "Levitate", "Lev", true, 1, levitate_descs, levitate_exe],
	"sssLllsrrrrrsll": [Pattern_Enum.teleport, "Teleport", "Tel", true, 2, teleport_descs, teleport_exe],
}

# ---------------------- End (yay) ---------------------- #
