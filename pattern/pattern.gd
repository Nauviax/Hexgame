class_name Pattern

# List of grid points that make up this pattern.
# in_use should be set false before deleting this pattern.
# (Note that points do not necessarily match line points, though they will on _init.)
var points = []

# The Line2D object that represents this pattern.
# Held here so it can be deleted when this pattern is deleted.
var line = null

# String that represents the pattern.
# First character is the initial direction: 1-6 starting NE and going clockwise.
# Subsequent characters are one from [L, l, s, r, R], representing hard left, left, straight etc.
var p_code = ""

# Name and validity of this pattern.
var name = ""
var is_valid = false

# Executable code for this pattern.
var p_exe_name # Used to load executable code. "Mind's Reflection" would become "minds_reflection"
var p_exe = null

# The value of this pattern. Relevant only for dynamic patterns.
# For numerical reflection, this is just the number.
# For bookkeeper's gambit, treat as binary where 1 is keep and 0 is discard.
#	(And a reminder, the last bit (1s column) is the top of the stack)
var value = 0.0

# Pattern constructor. Takes points and line, then calculates p_code.
func _init(point_init, line_init):
	points = point_init
	# All points are now in use.
	for pnt in points:
		pnt.in_use = true
	line = line_init
	p_code = Pattern.calc_p_code(points)
	# Get pattern name and validity, then get executable code.
	Valid_Patterns.set_pattern_name(self)
	p_exe_name = name.to_lower().replace(" ", "_").replace("'", "").replace(":", "")
	p_exe = load("res://pattern/exe_folder/" + p_exe_name + ".gd")

# Execute the pattern on the given stack
func execute(hexlogic):
	var iota_count = p_exe.iota_count
	if hexlogic.stack.size() < iota_count:
		hexlogic.stack.push_back(Bad_Iota.new())
		return "Error: Not enough iotas in stack"
	return p_exe.execute(hexlogic, self)

# Calculates p_code from points.
static func calc_p_code(points):
	# Get the initial direction.
	var dir = get_dir(points[0], points[1])
	var dir2 = -1 # Used in for loop
	var p_code = str(dir) # The return value. Starts with a num, then letters.
	# For every other point, get the turn from the previous point.
	for ii in range(2, points.size()):
		dir2 = get_dir(points[ii-1], points[ii])
		p_code += get_turn(dir, dir2)
		dir = dir2
	return p_code

# Calculates the direction from point a to point b. (1-6 starting NE and going clockwise.)
static func get_dir(a, b):
	var x = b.x_id - a.x_id
	var y = b.y_id - a.y_id
	if x == 0:
		if y == 1:
			return 3
		else: # y == -1
			return 6
	elif x == 1:
		if y == 0:
			return 2
		else: # y == -1
			return 1
	else: # x == -1
		if y == 0:
			return 5
		else: # y == 1
			return 4

# Calculates the turn from direction a to direction b. (L, l, s, r, R)
# Inputs are 1-6 starting NE and going clockwise.
static func get_turn(a, b):
	var turn = b - a
	if turn < 0: # Avoid negative numbers
		turn += 6
	match turn:
		0:
			return "s"
		1:
			return "r"
		2:
			return "R"
		4:
			return "L"
		5:
			return "l"
		_:
			return null # Should never happen. (This is also the "3" case.)

# Delete this pattern, freeing up all points and removing line graphic.
# (Technically this pattern object still sticks around, but I think it'll get cleaned up. Check back if memory leaks.)
func delete():
	# Free up all points.
	for pnt in points:
		pnt.in_use = false
	points.clear()
	# Remove line graphic.
	line.queue_free()
	# Misc
	p_exe = null

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
	
