class_name ErrorMM

enum {
	WRONG_ARG_COUNT, # Expected a specific number of arguments, but recieved too few. Takes two arguments: expected count, got count
	WRONG_ARG_TYPE, # Expected an argument of a specific type, but got a different type. Takes two arguments: expected location, expected type, got iota
	WRONG_ARG_PAIR, # Expected a pair of arguments, but the pair didn't match any expected pair type. Takes two arguments: got iota 1, got iota 2

	INVALID_PATTERN, # The pattern provided was invalid. Takes one argument: p_code
	DIV_BY_ZERO, # Attempted to divide by zero. Takes no arguments
	OUT_OF_RANGE, # The provided number was out of range. Takes four arguments: expected location, min, max, got iota. (Pass "any" for min or max if none)

	NOT_LEVEL_HAVER, # Attempted to use a level-haver-based function on a non-level-haver. Takes no arguments
	BAD_EVANITION, # Evanition executed outside of Introspection. Takes no arguments
	CASTER_IN_RANGE, # Attempted to cast a spell in range of the caster, when the caster can't be in range of the spell. Takes no arguments
	LIST_CONTAINS_INVALID, # A list contains an invalid iota. Takes four arguments: expected location, expected type, got iota index, got iota
	NO_SENTINEL, # Tried to access the sentinel while it was null. Takes no arguments
	HASTY_RETROSPECTION, # Retrospection executed without a previous matching Introspection. Takes no arguments
	NO_GATE, # Vector given to teleport did not lead to a gate. Takes two arguments: Given vector, "gate" pos

	DELVED_TOO_DEEP, # Execution depth exceeded the maximum. Takes one argument: current depth
	CASTING_DISABLED, # Attempted to cast a pattern, but casting is disabled. Takes no arguments
	CUSTOM, # Custom error message. Takes one argument: The message. Not recommended to be used as can be hard to make changes.
	NONE # No error message. Used for invalid game states, or whenever code doesn't know what error to throw. Ideally never used or at least never called.
}

# For the purposes of expected types, patterns can also use "number/vector" to specify multiple types, "entity (player)" to be more specific, or "(many)" if many types are allowed.

# For all vars, use lowercase as inputs.
static func make(type: int, name: String,  var1 = null, var2 = null, var3 = null, var4 = null):
	var error_str = name + " :: " # All error messages start with the name of the pattern that threw the error
	match type:
		WRONG_ARG_COUNT:
			error_str += "Not enough iotas in stack. Expected " + str(var1) + ", got " + str(var2) + "."
		WRONG_ARG_TYPE:
			error_str += "Wrong iota type at index " + str(var1) + ". Expected " + var2 + ", got " + get_type(var3) + "."
		WRONG_ARG_PAIR:
			error_str += "Invalid pair of iotas. Got " + get_type(var1) + " and " + get_type(var2) + "."
		INVALID_PATTERN:
			error_str += "No pattern match found. P_CODE: " + var1 + "."
		DIV_BY_ZERO:
			error_str += "Attempted to divide by zero. (You fool)"
		OUT_OF_RANGE:
			error_str += "Iota at index " + str(var1) + " is out of range. Expected " + str(var2) + " to " + str(var3) + " (Inclusive), got " + str(var4) + "."
		NOT_LEVEL_HAVER:
			error_str += "Entity is not a level-haver."
		BAD_EVANITION:
			error_str += "Evanition executed outside of Introspection."
		CASTER_IN_RANGE:
			error_str += "Caster is in range of spell, but this is not allowed."
		LIST_CONTAINS_INVALID:
			error_str += "List at index " + str(var1) + " contains an invalid iota. Expected " + var2 + " at list index " + str(var3) + ", got " + get_type(var4) + "."
		NO_SENTINEL:
			error_str += "Sentinel is not summoned."
		HASTY_RETROSPECTION:
			error_str += "Retrospection executed without a previous matching Introspection."
		NO_GATE:
			error_str += "Vector " + str(var1) + " leads to " + str(var2) + ", but there is no gate there."
		DELVED_TOO_DEEP:
			error_str += "Execution depth exceeded the maximum. Current depth: " + str(var1) + "."
		CASTING_DISABLED:
			error_str += "Casting is disabled."
		CUSTOM:
			error_str += var1
		NONE:
			error_str += "Unknown error. This is a problem with the game's code." # "Default" case
	return error_str

# Returns the type of the given iota
static func get_type(iota):
	if iota == null:
		return "null"
	if iota is int:
		printerr("WARNING: int in stack. (Part of recent Bad_Iota)")
		return "int (PLEASE REPORT THIS TO DEV)" # No ints should be in the stack
	if iota is float:
		return "number"
	if iota is String:
		return "string"
	if iota is bool:
		return "bool"
	if iota is Vector2:
		return "vector"
	if iota is Array:
		return "list" # Might consider changing to array (EVERYWHERE) if confusing
	if iota is Entity:
		return "entity"
	if iota is Pattern:
		return "pattern"
	if iota is Bad_Iota:
		return "bad iota"
	return "unknown" # Default case
