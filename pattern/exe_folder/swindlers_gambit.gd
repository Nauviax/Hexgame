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

# Note: I give up on coding this properly for now, so I'm hardcoding it with a dictionary up to 5 long.
static var descs = [
	"Given a number (TOP) Rearranges the rest of the top elements on the stack based on the given numerical code (TOP). See 'Lehmer codes' for info, or see next page.",
    "This game only supports rearranging up to 5 elements, based on those at github.com/FallingColors/HexMod/wiki/Table-of-Lehmer-Codes-for-Swindler's-Gambit. Good luck copying that link though.", # !!! Include a link to ingame resource later somehow?
    "An example of what to expect: given a stack 'cba' where a is top iota, code 0 gives cba, 1 -> cab, 2 -> bca, 3 -> bac, 4 -> acb, 5 -> abc etc. etc. This goes on for a long time.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, pattern):
	var stack = hexecutor.stack
	var num = stack.pop_back()
	if not num is float:
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_TYPE, pattern.name, 0, "number", num))
		return false
	if num < 0 or num > 119:
		stack.push_back(Bad_Iota.new(ErrorMM.OUT_OF_RANGE, pattern.name, 0, 0, 119, num))
		return false
	var code = lehmer[int(num)]
	var iotas = [] # Stored in order abcde (flipped compared to lehmer code)
	# Ensure enough iotas
	if len(code) > stack.size():
		stack.push_back(Bad_Iota.new(ErrorMM.WRONG_ARG_COUNT, pattern.name, len(code), stack.size()))
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
static var lehmer = {
	0 : "a",
    1 : "ab",
    2 : "bca",
    3 : "bac",
    4 : "acb",
    5 : "abc",
    6 : "cdba",
    7 : "cdab",
    8 : "cbda",
    9 : "cbad",
    10 : "cadb",
    11 : "cabd",
    12 : "bdca",
    13 : "bdac",
    14 : "bcda",
    15 : "bcad",
    16 : "badc",
    17 : "bacd",
    18 : "adcb",
    19 : "adbc",
    20 : "acdb",
    21 : "acbd",
    22 : "abdc",
    23 : "abcd",
    24 : "decba",
    25 : "decab",
    26 : "debca",
    27 : "debac",
    28 : "deacb",
    29 : "deabc",
    30 : "dceba",
    31 : "dceab",
    32 : "dcbea",
    33 : "dcbae",
    34 : "dcaeb",
    35 : "dcabe",
    36 : "dbeca",
    37 : "dbeac",
    38 : "dbcea",
    39 : "dbcae",
    40 : "dbaec",
    41 : "dbace",
    42 : "daecb",
    43 : "daebc",
    44 : "daceb",
    45 : "dacbe",
    46 : "dabec",
    47 : "dabce",
    48 : "cedba",
    49 : "cedab",
    50 : "cebda",
    51 : "cebad",
    52 : "ceadb",
    53 : "ceabd",
    54 : "cdeba",
    55 : "cdeab",
    56 : "cdbea",
    57 : "cdbae",
    58 : "cdaeb",
    59 : "cdabe",
    60 : "cbeda",
    61 : "cbead",
    62 : "cbdea",
    63 : "cbdae",
    64 : "cbaed",
    65 : "cbade",
    66 : "caedb",
    67 : "caebd",
    68 : "cadeb",
    69 : "cadbe",
    70 : "cabed",
    71 : "cabde",
    72 : "bedca",
    73 : "bedac",
    74 : "becda",
    75 : "becad",
    76 : "beadc",
    77 : "beacd",
    78 : "bdeca",
    79 : "bdeac",
    80 : "bdcea",
    81 : "bdcae",
    82 : "bdaec",
    83 : "bdace",
    84 : "bceda",
    85 : "bcead",
    86 : "bcdea",
    87 : "bcdae",
    88 : "bcaed",
    89 : "bcade",
    90 : "baedc",
    91 : "baecd",
    92 : "badec",
    93 : "badce",
    94 : "baced",
    95 : "bacde",
    96 : "aedcb",
    97 : "aedbc",
    98 : "aecdb",
    99 : "aecbd",
    100 : "aebdc",
    101 : "aebcd",
    102 : "adecb",
    103 : "adebc",
    104 : "adceb",
    105 : "adcbe",
    106 : "adbec",
    107 : "adbce",
    108 : "acedb",
    109 : "acebd",
    110 : "acdeb",
    111 : "acdbe",
    112 : "acbed",
    113 : "acbde",
    114 : "abedc",
    115 : "abecd",
    116 : "abdec",
    117 : "abdce",
    118 : "abced",
    119 : "abcde"
} 
