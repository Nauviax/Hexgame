class_name Pattern
extends Resource # Should mean this object gets deleted automatically when not in use.

# String that represents the pattern.
# First character is the initial direction: 1-6 starting NE and going clockwise.
# Subsequent characters are one from [L, l, s, r, R], representing hard left, left, straight etc.
var p_code = ""

# Various pattern features
var name = "" # Used for display in gui and identification in code
var name_short = "" # Shorter, non-unique name for use in lists (Not set for some dynamic patterns. Normally because value is shown instead)
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
var value = null

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
		hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, name, iota_count, hexecutor.stack.size()))
		return false
	return p_exe.execute(hexecutor, self)

# _to_string override for fancy display
# This function returns a shorthand name for the pattern, for use in lists.
# To get the full length name, use pattern.get_meta_string() (Rather than str(pattern))
func _to_string():
	return get_meta_string(true)

# Like _to_string, but returns the full name of the pattern.
func get_meta_string(short = false):
	var text
	if is_valid:
		if name == "Numerical Reflection":
			text = "(" + str(value) + ")" if short else "Numerical Reflection (" + str(value) + ")"
		elif name == "Bookkeeper's Gambit":
			var str_gambit = Pattern.value_to_bookkeeper(value)
			text = "(" + str_gambit + ")" if short else "Bookkeeper's Gambit (" + str_gambit + ")"
		else: # Default case
			text = name_short if short else name
	else:
		text = "(" + p_code + ")" if short else "Invalid Pattern (" + p_code + ")"
	var return_val = "[url=P" + p_code + "]" + text + "[/url]" # Text will contain p_code as metadata
	if not short:
		return_val += " " # Fix for hover hitbox covering entire width of text label.
	return return_val
	
# Static function to convert a value (number) to a bookkeeper's gambit string
static func value_to_bookkeeper(value):
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
	return str_gambit

# For use in create_line
static var line_scene = preload("res://resources/shaders/cast_line/cast_line.tscn")
static var line_gradient = preload("res://resources/shaders/cast_line/gradient_textures/normal.tres")
static var vector_offsets = [ # Unit distance * 50
	Vector2(25, -43.3), # Top right
	Vector2(50, 0), # Right
	Vector2(25, 43.3), # Bottom right
	Vector2(-25, 43.3), # Bottom left 
	Vector2(-50, 00), # Left
	Vector2(-25, -43.3) # Top left
]

# Creates and returns a Line2D object that represents the pattern.
# Static so pattern object isn't required.
static func create_line(p_code: String):
	var line = line_scene.instantiate()
	line.prep_line() # Creates material duplicate
	line.add_point(Vector2(0, 0))
	line.material.set_shader_parameter("gradient_texture", line_gradient)
	# Line initial point at 0,0. Every char in p_code places a new point 1 unit away from the last.
	# First char is initial direction, 1 being top right, 2 being right, etc to 6 being top left.
	# Afterwards, L, l, s, r, R are hard left, left, straight, right, hard right. All on hex coordinates.
	var first = p_code.substr(0, 1).to_int()
	var dir = first - 1 # 1 is top right, which is index 0.
	var pos = vector_offsets[dir] # Initial position
	line.add_point(pos) 
	var rest = p_code.substr(1)
	for cc in rest:
		match cc:
			"L": dir = (dir - 2) % 6
			"l": dir = (dir - 1) % 6
			"s": pass # No change
			"r": dir = (dir + 1) % 6
			"R": dir = (dir + 2) % 6
		pos += vector_offsets[dir]
		line.add_point(pos)
	line.material.set_shader_parameter("segments", line.points.size() - 1.0) # Scale shader animation
	# Scale and centre the line
	var average = Vector2(0, 0)
	var max_x = 0
	var max_y = 0
	var min_x = 0
	var min_y = 0
	for point in line.points: # Calculate average, and get min + max points
		average += point
		if point.x > max_x:
			max_x = point.x
		elif point.x < min_x:
			min_x = point.x
		if point.y > max_y:
			max_y = point.y
		elif point.y < min_y:
			min_y = point.y
	average /= line.points.size()
	var dist_x = max_x - min_x
	var dist_y = max_y - min_y
	var scale
	if dist_x > dist_y: # Scale based on largest distance. Small patterns treated as distance = 60 (A single line L->R is 50 units long)
		scale = 135 / max(dist_x, 60) # If pattern is longer than it is tall, scale less harshly. Window is wider than it is tall.
	else:
		scale = 100 / max(dist_y, 60)
	line.scale = Vector2(scale, scale)
	line.position = -average * scale
	return line
