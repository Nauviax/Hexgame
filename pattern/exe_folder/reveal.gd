# Reveals the top value of the stack.
# This will save the iota to level_base, which then gets displayed by hex_display.
static var descs = [
	"This pattern copies the top iota and saves it to the level. Many levels will require you to reveal a specific iota to beat them.",
]
static var iota_count = 1
static var is_spell = true # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.log_spellbook_change(11) # Revealed iota is changed
	hexecutor.level_base.revealed_iota = hexecutor.stack[-1]
	return true