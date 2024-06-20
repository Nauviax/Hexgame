# Removes the caster's sentinel.
static var descs = [
	"Removes the caster's sentinel.",
]
static var iota_count = 0
static var is_spell = false # If this pattern changes the level in any way.
static func execute(hexecutor, _pattern):
	hexecutor.log_spellbook_change(10) # Sentinel is changed
	var player = hexecutor.caster.node
	if player.sentinel_pos != null: # No extra particles if no sentinel
		player.particle_target(Entity.fake_to_real(player.sentinel_pos)) # Particles
	player.set_sentinel(null)
	return true
