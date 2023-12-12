class_name Valid_Patterns

# Sets the name and validity of the given pattern
# Returns true on success. Blank string name on failure.
static func set_pattern_name(pattern):
	var raw_code = pattern.p_code.right(-1) # Drop the initial number

	# Check if raw_code is a Numerical Reflection
	if numerical_check(pattern, raw_code):
		pattern.is_valid = true
		return

	# Check if raw_code is a Bookkeeper's Gambit
	if bookkeeper_check(pattern, raw_code):
		pattern.is_valid = true
		return
	
	# Check if raw_code is a static pattern
	if raw_code in static_patterns:
		pattern.name = static_patterns[raw_code]
		pattern.is_valid = true
		return
	
	# Otherwise, pattern is invalid
	pattern.name = "Invalid Pattern"
	pattern.is_valid = false
	return
	
# ---------------------- #

# Dictionary of static patterns. Key maps to pattern name.
# Key is the raw_code value, which excludes p_code's initial number (Rotation is irrelevant)
static var static_patterns = {
	# Basic Patterns
	"LL": "Compass' Purification",
	"lLl": "Mind's Reflection",
	"sL": "Alidade's Purification",
	"sl": "Pace Purification",
	"Rr": "Reveal",
	"slLLsRR": "Archer's Distillation",
	"srRRsLL": "Architect's Distillation",
	"srLlL": "Scout's Distillation",

	# Mathematics
	"slLls": "Length Purification",
	"sLLs": "Additive Distillation",
	"sRRs": "Subtractive Distillation",
	"sLlLs": "Multiplicative Distillation",
	"sRrRs": "Division Distillation",
	"lsr": "Ceiling Purification",
	"rsl": "Floor Purification",
	"lllllLss": "Axial Purification",
	"rlllll": "Vector Distillation",
	"lrrrrr": "Vector Decomposition",
	"LRRsLLR": "Modulus Distillation",
	"srRrs": "Power Distillation",
	"rlll": "Entropy Reflection",

	# Constants
	"LLl": "Euler's Reflection",
	"lRsRl": "Arc's Reflection",
	"rLsLr": "Circle's Reflection",
	"RrRl": "False Reflection",
	"LlLr": "True Reflection",
	"R": "Nullary Reflection",
	"lllll": "Vector Reflection Zero",
	"rrrrrlL": "Vector Reflection Neg X",
	"lllllrL": "Vector Reflection Pos X",
	"rrrrrlR": "Vector Reflection Neg Y",
	"lllllrR": "Vector Reflection Pos Y",

	# Stack Manipulation
	"LLRLRLLs": "Dioscuri Gambit",
	"LLRLL": "Gemini Decomposition",
	"LLRLLRLL": "Gemini Gambit",
	"RRLR": "Fisherman's Gambit",
	"LLRL": "Fisherman's Gambit Ii",
	"LLrRR": "Prospector's Gambit",
	"LLrLL": "Rotation Gambit",
	"RRlRR": "Rotation Gambit Ii",
	"lsLrLslLrLlL": "Flock's Reflection",
	"LLsRR": "Jester's Gambit",
	"lLLsRRr": "Swindler's Gambit",
	"RRlLL": "Undertaker's Gambit",

	# Logical Operators
	"sRs": "Conjunction Distillation",
	"Ls": "Augur's Purification",
	"LR": "Equality Distillation",
	"r": "Maximus Distillation",
	"rr": "Maximus Distillation II",
	"LsRR": "Augur's Exaltation",
	"l": "Minimus Distillation",
	"ll": "Minimus Distillation II",
	"Rs": "Negation Purification",
	"RL": "Inequality Distillation",
	"sLs": "Disjunction Distillation",
	"RsL": "Exclusion Distillation",
	
	# Entities
	"lllllRLlL": "Entity Purification",
	"lllllRLlLLss": "Entity Purification: Neutral",
	"lllllRLlLLsl": "Entity Purification: Hostile",
	"lllllRLlLLsr": "Entity Purification: Friendly",
	"lllllsRrR": "Zone Distillation: Any",
	"lllllsRrRRss": "Zone Distillation: Neutral",
	"lllllsRrRRsl": "Zone Distillation: Hostile",
	"lllllsRrRRsr": "Zone Distillation: Friendly",
	"rrrrrsLlLLss": "Zone Distillation: Non-Neutral",
	"rrrrrsLlLLsl": "Zone Distillation: Non-Hostile",
	"rrrrrsLlLLsr": "Zone Distillation: Non-Friendly",

	# List Manipulation
	"rRlRr": "Integration Distillation",
	"lLrLl": "Derivation Decomposition",
	"RRrsrRR": "Speaker's Distillation",
	"LLlslLL": "Speaker's Decomposition",
	"llLrLLr": "Vacant Reflection",
	"RrrrR": "Selection Distillation",
	"lLrLlsRrR": "Selection Exaltation",
	"RrRlRr": "Locator's Distillation",
	"rsRlRsr": "Flock's Gambit",
	"lsLrLsl": "Flock's Disintegration",
	"rRlRrsLlL": "Excisor's Distillation",
	"slLrLls": "Surgeon's Exaltation",
	"lllLrRr": "Retrograde Purification",
	"LRrrrR": "Single's Purification",

	# Escaping Patterns
	"lllLs": "Consideration",
	"lll": "Introspection",
	"rrr": "Retrospection",
	"rrrRs": "Evanition",

	# Reading and Writing
	"Llllll": "Scribe's Reflection",
	"sLslslslslsls": "Chronicler's Purification",
	"lrrsRsrRRs": "Muninn's Reflection",
	"Llllllr": "Auditor's Reflection",
	"sLslslslslslsrs": "Auditor's Purification",
	"Rrrrrrl": "Assessor's Reflection",
	"sRsrsrsrsrsrsls": "Assessor's Purification",
	"Rrrrrr": "Scribe's Gambit",
	"sRsrsrsrsrsrs": "Chronicler's Gambit",
	"rllsLslLLs": "Huginn's Gambit",

	# Advanced Mathematics
	"lllllLR": "Cosine Purification",
	"lllllLL": "Sine Purification",
	"slllllLRl": "Tangent Purification",
	"LRrrrrr": "Inverse Cosine Purification",
	"RRrrrrr": "Inverse Sine Purification",
	"rLRrrrrrs": "Inverse Tangent Purification",
	"RrLRrrrrrsR": "Inverse Tangent Purification II",
	"rlLlr": "Logarithmic Distillation",

	# Sets (Mainly in Logical Operators now)
	"LsrLlL" : "Uniqueness Purification",

	# Meta-Evaluation
	"RrLll" : "Hermes' Gambit",


	### NEW PATTERNS ###

	# Spellbook
	"RsrsRsr": "Verso's Gambit",
	"lsLslsL": "Recto's Gambit",
	"RsrsRsrRs": "Tome's Reflection",
	"lsLslsLls": "Tome's Gambit",
}

# ---------------------- #

# Checks if the given pattern is a Bookkeeper's Gambit
# Bookkeeper's is made from a chain of characters in a specific order.
# If the FIRST character is an "L", we just drew a 1. If it's an "s", we've drawn TWO 0s. (Yes two)
# 	Additionally, if first char is "r" followed by "L", we've drawn a 0 and a 1.
# After drawing a 1, "RL" is another 1, "r" is a 0.
# After drawing a 0, "rL" is a 1, "s" is another 0.
# If at any point (First char, after 1, after 0) the next character(s) do not match these rules, return false.
# 1s and 0s are saved to the value var. To write a single value, bitshift value left by 1 and add 1 or 0.
static func bookkeeper_check(pattern, raw_code):
	# First check empty raw_code. This actually is a valid bookkeeper's gambit.
	if len(raw_code) == 0:
		pattern.name = "Bookkeeper's Gambit"
		pattern.value = 0 # A single line just means keep.
		return true

	var value = 0 # Value to be written to pattern. In binary, 0 means keep, 1 means toss.
					# The least significant bit is the top of the stack.
	var ii = 0 # Char being read
	var state = 2 # Represents last drawn value. 0 = 0, 1 = 1, 2 = start.
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
	pattern.name = "Bookkeeper's Gambit"
	pattern.value = value
	return true

# ---------------------- #

# Checks if the given pattern is a Numerical Reflection
# Check is done by viewing first 4 characters of raw_code
# Will set name and value of pattern on match.
static func numerical_check(pattern, raw_code):
	# First check that raw_code is at least 4 characters long
	if len(raw_code) < 4:
		return false
	# Then check if first 4 characters match a numerical reflection
	if raw_code.left(4) == "LlLL":
		pattern.name = "Numerical Reflection"
		pattern.value = calculate_num(raw_code.right(-4))
		return true
	elif raw_code.left(4) == "RrRR":
		pattern.name = "Numerical Reflection"
		pattern.value = calculate_num(raw_code.right(-4)) * -1
		return true
	else:
		return false


# Calculates the numeric value of a numerical reflection.
# Pass in only the dynamic part of the code. Not the entire raw_code.
# Returns only positive values.
static func calculate_num(code):
	var value = 0.0
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
