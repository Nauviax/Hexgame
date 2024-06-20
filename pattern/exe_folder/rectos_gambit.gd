# Increments the caster's selected spellbook page.
static var descs = [
	"Increments the caster's selected spellbook page.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.tracker_sb_selected_changed = true # sb selection is changed
	hexecutor.caster.node.inc_sb() 
	return true