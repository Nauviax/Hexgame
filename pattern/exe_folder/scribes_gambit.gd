# Remove the top iota from the stack, and save it into the caster's selected spellbook page.
static var descs = [
	"Removes the top iota from the stack, and saves it into the caster's selected spellbook page.",
]
static var iota_count = 1
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	var player = hexecutor.caster.node
	hexecutor.log_spellbook_change(player.sb_sel) # Spellbook item is changed
	player.set_iota(hexecutor.stack.pop_back())
	return true