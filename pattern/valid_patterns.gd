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
		var name_pair = static_patterns[raw_code]
		pattern.name = name_pair[0]
		pattern.name_short = name_pair[1]
		pattern.is_valid = true
		return
	
	# Otherwise, pattern is invalid
	pattern.name = "Invalid Pattern"
	pattern.is_valid = false
	return
	
# ---------------------- #

# Dictionary of static patterns. Key maps to a short array, where the first item is the name of the pattern, and the second is a NON-UNIQUE short name version.
# Key is the raw_code value, which excludes p_code's initial number (Rotation is irrelevant)
# Short names for Numerical Reflection and Bookkeeper's Gambit are just their value, and Invalid Pattern just it's p_code.
static var static_patterns = { # !!! I would like to remove short names somehow, but need lists of patterns to display nicer.
	# Basic Patterns
	"LL": ["Compass' Purification", "ComPu"],
	"lLl": ["Mind's Reflection", "MinRe"],
	"sL": ["Alidade's Purification", "AliPu"],
	"sl": ["Pace Purification", "PacPu"],
	"Rr": ["Reveal", "Rev"],
	"slLLsRR": ["Archer's Distillation", "ArcDi"],
	"srRRsLL": ["Architect's Distillation", "ArcDi"], # Same short name, but eh they can hover for full name if confused.
	"srLlL": ["Scout's Distillation", "ScoDi"],

	# Mathematics
	"slLls": ["Length Purification", "LenPu"],
	"sLLs": ["Additive Distillation", "AddDi"],
	"sRRs": ["Subtractive Distillation", "SubDi"],
	"sLlLs": ["Multiplicative Distillation", "MulDi"],
	"sRrRs": ["Division Distillation", "DivDi"],
	"lsr": ["Ceiling Purification", "CeiPu"],
	"rsl": ["Floor Purification", "FloPu"],
	"lllllLss": ["Axial Purification", "AxiPu"],
	"rlllll": ["Vector Distillation", "VecDi"],
	"lrrrrr": ["Vector Decomposition", "VecDe"],
	"LRRsLLR": ["Modulus Distillation", "ModDi"],
	"srRrs": ["Power Distillation", "PowDi"],
	"rlll": ["Entropy Reflection", "EntRe"],

	# Constants
	"LLl": ["Euler's Reflection", "EulRe"],
	"lRsRl": ["Arc's Reflection", "ArcRe"],
	"rLsLr": ["Circle's Reflection", "CirRe"],
	"RrRl": ["False Reflection", "FalRe"],
	"LlLr": ["True Reflection", "TruRe"],
	"R": ["Nullary Reflection", "NulRe"],
	"lllll": ["Vector Reflection Zero", "VecZe"],
	"rrrrrlL": ["Vector Reflection Neg X", "VecNX"],
	"lllllrL": ["Vector Reflection Pos X", "VecPX"],
	"rrrrrlR": ["Vector Reflection Neg Y", "VecNY"],
	"lllllrR": ["Vector Reflection Pos Y", "VecPY"],

	# Stack Manipulation
	"LLRLRLLs": ["Dioscuri Gambit", "DioGa"],
	"LLRLL": ["Gemini Decomposition", "GemDe"],
	"LLRLLRLL": ["Gemini Gambit", "GemGa"],
	"RRLR": ["Fisherman's Gambit", "FisGa"],
	"LLRL": ["Fisherman's Gambit II", "FisGa"],
	"LLrRR": ["Prospector's Gambit", "ProGa"],
	"LLrLL": ["Rotation Gambit", "RotGa"],
	"RRlRR": ["Rotation Gambit II", "RotGa"],
	"lsLrLslLrLlL": ["Flock's Reflection", "FloRe"],
	"LLsRR": ["Jester's Gambit", "JesGa"],
	"lLLsRRr": ["Swindler's Gambit", "SwiGa"],
	"RRlLL": ["Undertaker's Gambit", "UndGa"],

	# Logical Operators
	"sRs": ["Conjunction Distillation", "ConDi"],
	"Ls": ["Augur's Purification", "AugPu"],
	"LR": ["Equality Distillation", "EquDi"],
	"r": ["Maximus Distillation", "MaxDi"],
	"rr": ["Maximus Distillation II", "MaxDi"],
	"LsRR": ["Augur's Exaltation", "AugEx"],
	"l": ["Minimus Distillation", "MinDi"],
	"ll": ["Minimus Distillation II", "MinDi"],
	"Rs": ["Negation Purification", "NegPu"],
	"RL": ["Inequality Distillation", "IneDi"],
	"sLs": ["Disjunction Distillation", "DisDi"],
	"RsL": ["Exclusion Distillation", "ExcDi"],
    
	# Entities
	"lllllRLlL": ["Entity Purification", "EntPu"],
	"lllllsRrR": ["Zone Distillation", "ZonDi"],

	# List Manipulation
	"rRlRr": ["Integration Distillation", "IntDi"],
	"lLrLl": ["Derivation Decomposition", "DerDe"],
	"RRrsrRR": ["Speaker's Distillation", "SpeDi"],
	"LLlslLL": ["Speaker's Decomposition", "SpeDe"],
	"llLrLLr": ["Vacant Reflection", "VacRe"],
	"RrrrR": ["Selection Distillation", "SelDi"],
	"lLrLlsRrR": ["Selection Exaltation", "SelEx"],
	"RrRlRr": ["Locator's Distillation", "LocDi"],
	"rsRlRsr": ["Flock's Gambit", "FloGa"],
	"lsLrLsl": ["Flock's Disintegration", "FloDi"],
	"rRlRrsLlL": ["Excisor's Distillation", "ExcDi"],
	"slLrLls": ["Surgeon's Exaltation", "SurEx"],
	"lllLrRr": ["Retrograde Purification", "RetPu"],
	"LRrrrR": ["Single's Purification", "SinPu"],

	# Escaping Patterns
	"lllLs": ["Consideration", "Con"],
	"lll": ["Introspection", "Int"],
	"rrr": ["Retrospection", "Ret"],
	"rrrRs": ["Evanition", "Eva"],

	# Reading and Writing
	"Llllll": ["Scribe's Reflection", "ScrRe"],
	"Rrrrrr": ["Scribe's Gambit", "ScrGa"],
	"Lllllls": ["Chronicler's Purification", "ChrPu"],
	"Rrrrrrs": ["Chronicler's Gambit", "ChrGa"],
	"Llllllsr": ["Auditor's Purification", "AudPu"],
	"Rrrrrrsl": ["Assessor's Purification", "AssPu"],
	"rllsLslLLs": ["Huginn's Gambit", "HugGa"],
	"lrrsRsrRRs": ["Muninn's Reflection", "MunRe"],

	# Advanced Mathematics
	"lllllLR": ["Cosine Purification", "CosPu"],
	"lllllLL": ["Sine Purification", "SinPu"],
	"slllllLRl": ["Tangent Purification", "TanPu"],
	"LRrrrrr": ["Inverse Cosine Purification", "InvCo"],
	"RRrrrrr": ["Inverse Sine Purification", "InvSi"],
	"rLRrrrrrs": ["Inverse Tangent Purification", "InvTa"],
	"RrLRrrrrrsR": ["Inverse Tangent Purification II", "InvTa"],
	"rlLlr": ["Logarithmic Distillation", "LogDi"],

    # Sets (Mainly in Logical Operators now)
    "LsrLlL" : ["Uniqueness Purification", "UniPu"],

    # Meta-Evaluation
    "RrLll" : ["Hermes' Gambit", "HerGa"],
    "LlRrr" : ["Charon's Gambit", "ChaGa"],
    "RLRLR" : ["Thoth's Gambit", "ThoGa"],

    ## ADDONS ##

    # Hexal Math
    "sLsRrRsLs" : ["Factorial Purification", "FacPu"],
    "LrL" : ["Running Sum Purification", "RunPu"],
    "lLLsLLl" : ["Running Product Purification", "RunPu"],

    ### NEW PATTERNS ###

    # Level access
    "llL": ["Enter", "Ent"],
    "llR": ["Exit", "Exi"],

    # Spellbook
    "RRl": ["Verso's Gambit", "VerGa"],
    "RRs": ["Recto's Gambit", "RecGa"],
    "LLs": ["Tome's Reflection", "TomRe"],
    "LLr": ["Tome's Gambit", "TomGa"],

    ## SPELLS ##

    # Sentinel
    "sLrLsLr": ["Summon Sentinel", "SumSe"],
    "lRsRlRs": ["Banish Sentinel", "BanSe"],
    "sLrLsLrRr": ["Locate Sentinel", "LocSe"],
    "sLrLsLrRsL": ["Wayfind Sentinel", "WaySe"],

    # Other
    "LLsLLsLL": ["Explosion", "Exp"],
    "LslllsLls": ["Impulse", "Imp"],
    "lllllLssLsLsR": ["Float", "Flo"],
    "sssLllsrrrrrsll": ["Teleport", "Tel"],
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