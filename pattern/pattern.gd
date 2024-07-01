class_name Pattern
extends Resource # Should mean this object gets deleted automatically when not in use.

# String that represents the pattern.
# First character is the initial direction: 1-6 starting NE and going clockwise.
# Subsequent characters are one from [L, l, s, r, R], representing hard left, left, straight etc.
var p_code: String

# More names that represent this pattern. Strings are pre-generated here to hopefully save on performance.
var name_internal: Valid_Patterns.Pattern_Enum # Used for pattern identification in code
var name_display: String # Nicer name to be shown to user. Shows extra content for dynamic patterns.
var name_short: String # Shorter, non-unique name for use in lists (Not set for some dynamic patterns. Normally because value is shown instead)
var name_display_meta: String # Name with metadata, for use when hover text is needed.
var name_short_meta: String # Short name with metadata, for use in lists.

# Various pattern features
var is_valid: bool = false # False if no matching pattern found in valid_patterns.gd
var is_spell: bool = false # Spells interact with the level in some way, and have their own sound effect.
# (Cont.) For our purposes, this includes patterns that get or read from / write to entities. For simplicity, so are Hermes and Thoth.
# Casting more than one spell will invalidate single-cast attempts for the current level.

# Executable information for this pattern.
var p_exe: Callable # Used to call relevant execute func. Takes Hexecutor and Pattern as arguments.
var p_exe_iota_count: int # Number of arguments this pattern requires on the stack. If variable, will be the minimum, or just 0.

# Description pages for this patten. This array will be shared so DO NOT MODIFY THE ARRAY.
var descs: Array

# The value of this pattern. Relevant only for dynamic patterns.
# For numerical reflection, this is just the number.
# For bookkeeper's gambit, treat as binary where 1 is keep and 0 is discard.
#	(And a reminder, the last bit (1s column) is the top of the stack)
var value: float = 0

# Pattern constructor. Takes a code string, then sets up pattern based on that.
func _init(p_code: String) -> void:
	self.p_code = p_code
	# Sets pattern name, validity, executable func, and other related data.
	Valid_Patterns.set_pattern_data(self)
	# Generate meta strings
	name_display_meta = "[url=P" + p_code + "]" + name_display + "[/url]"
	name_short_meta = "[url=P" + p_code + "]" + name_short + "[/url]"

# Execute the pattern on the given stack
func execute(hexecutor: Hexecutor) -> bool:
	if hexecutor.stack.size() < p_exe_iota_count:
		hexecutor.stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, name_display, p_exe_iota_count, hexecutor.stack.size()))
		return false
	return p_exe.call(hexecutor, self) # Call the pattern's execute function

# _to_string override for fancy display
# This function returns name_short_meta, for use in lists. Other strings can be grabbed from the object normally.
func _to_string() -> String:
	return name_short_meta

# For use in create_line
static var line_scene: PackedScene = preload("res://resources/shaders/cast_line/cast_line.tscn")
static var line_gradient: GradientTexture1D = preload("res://resources/shaders/cast_line/gradient_textures/normal.tres")
static var vector_offsets: Array = [ # Unit distance * 50
	Vector2(25, -43.3), # Top right
	Vector2(50, 0), # Right
	Vector2(25, 43.3), # Bottom right
	Vector2(-25, 43.3), # Bottom left 
	Vector2(-50, 00), # Left
	Vector2(-25, -43.3) # Top left
]

# Creates and returns a Line2D object that represents the pattern.
# Static so pattern object isn't required.
static func create_line(p_code: String) -> Line2D:
	var line: Line2D = line_scene.instantiate()
	line.prep_line() # Creates material duplicate
	line.add_point(Vector2(0, 0))
	line.material.set_shader_parameter("gradient_texture", line_gradient)
	# Line initial point at 0,0. Every char in p_code places a new point 1 unit away from the last.
	# First char is initial direction, 1 being top right, 2 being right, etc to 6 being top left.
	# Afterwards, L, l, s, r, R are hard left, left, straight, right, hard right. All on hex coordinates.
	var first: int = p_code.substr(0, 1).to_int()
	var dir: int = first - 1 # 1 is top right, which is index 0.
	var pos: Vector2 = vector_offsets[dir] # Initial position
	line.add_point(pos) 
	var rest: String = p_code.substr(1)
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
	var average: Vector2 = Vector2(0, 0)
	var max_x: float = 0
	var max_y: float = 0
	var min_x: float = 0
	var min_y: float = 0
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
	var dist_x: float = max_x - min_x
	var dist_y: float = max_y - min_y
	var scale: float
	if dist_x > dist_y: # Scale based on largest distance. Small patterns treated as distance = 67 (A single line L->R is 50 units long)
		scale = 135 / max(dist_x, 67) # If pattern is longer than it is tall, scale less harshly. Window is wider than it is tall.
	else:
		scale = 100 / max(dist_y, 67)
	line.scale = Vector2(scale, scale)
	line.position = -average * scale
	return line
