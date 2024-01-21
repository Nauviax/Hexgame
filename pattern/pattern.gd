class_name Pattern
extends Resource # Should mean this object gets deleted automatically when not in use.

# String that represents the pattern.
# First character is the initial direction: 1-6 starting NE and going clockwise.
# Subsequent characters are one from [L, l, s, r, R], representing hard left, left, straight etc.
var p_code = ""

# Various pattern features
var name = ""
var is_valid = false # False if no matching pattern found in valid_patterns.gd
var is_spell = false # Spells interact with the level in some way, and have their own sound effect.
# (Cont.) For our purposes, this includes patterns that get or read from / write to entities. For simplicity, so are Hermes and Thoth.
# Casting more than one spell will invalidate single-cast attempts for the current level.

# Executable code for this pattern.
var p_exe_name # Used to load executable code. "Mind's Reflection" would become "minds_reflection"
var p_exe = null

# The value of this pattern. Relevant only for dynamic patterns.
# For numerical reflection, this is just the number.
# For bookkeeper's gambit, treat as binary where 1 is keep and 0 is discard.
#	(And a reminder, the last bit (1s column) is the top of the stack)
var value = 0.0

# Pattern constructor. Takes a code string, then sets up pattern based on that.
func _init(p_code: String):
	self.p_code = p_code
	# Get pattern name and validity, then get executable code.
	Valid_Patterns.set_pattern_name(self)
	p_exe_name = name.to_lower().replace(" ", "_").replace("'", "").replace(":", "")
	p_exe = load("res://pattern/exe_folder/" + p_exe_name + ".gd")
	is_spell = p_exe.is_spell # Set spell status

# Execute the pattern on the given stack
func execute(hexecutor):
	var iota_count = p_exe.iota_count
	if hexecutor.stack.size() < iota_count:
		hexecutor.stack.push_back(Bad_Iota.new())
		return "Error: Not enough iotas in stack"
	return p_exe.execute(hexecutor, self)

# _to_string override for fancy display
func _to_string():
	if is_valid:
		if name == "Numerical Reflection":
			return "Numerical Reflection (" + str(value) + ")"
		elif name == "Bookkeeper's Gambit":
			var val_clone = value
			var str_gambit = ""
			# Treat value as binary, if bit is 1, add "x" to string, if bit is 0, add "-" to string
			while val_clone > 0:
				if val_clone % 2 == 1:
					str_gambit = "x" + str_gambit
				else:
					str_gambit = "-" + str_gambit
				val_clone = val_clone >> 1
			if str_gambit == "": # For the do-nothing gambit
				str_gambit = "-"
			return "Bookkeeper's Gambit (" + str_gambit + ")"
		# Default case
		else:
			return name
	else:
		return "Invalid Pattern (" + p_code + ")"
	
