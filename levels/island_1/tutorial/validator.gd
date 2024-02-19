# Tutorial Validator
static var descs = [
	"Tutorial step 1/4: Reveal yourself by casting [url=P1lLl]Mind's Reflection[/url] then [url=P1Rr]Reveal[/url].",
	"Tutorial step 2/4: Reveal the iota contained in the entity in the next room. [url=P2srLlL]Scout's[/url] can be used to get the entity, and [url=P2sLslslslslsls]Chronicler's[/url] to read it's iota. Remember to see Hexbook for other needed patterns.",
	"Tutorial step 3/4: Move the entity onto the red area past the spikes. [url=P5lllllLssLsLsR]Float[/url] and [url=P4LslllsLls]Impulse[/url] should be used. Number/Vector patterns are in the Hexbook.",
	"Tutorial step 4/4: Finish on the green area by teleporting through the glass using [url=P2sssLllsrrrrrsllsllsssllrllsssll]Teleport[/url].",
]
static func validate(level_base):
	match level_base.level_progress:
		0:
			if level_base.revealed_iota is Entity and level_base.revealed_iota == level_base.player.entity:
				level_base.level_progress = 1
				level_base.level_desc = descs[1]
				level_base.initiator.gate1.queue_free()
				return false
		1:
			if level_base.revealed_iota is float and level_base.revealed_iota == level_base.initiator.iota:
				level_base.level_progress = 2
				level_base.level_desc = descs[2]
				level_base.initiator.gate2.queue_free()
				return false
		2:
			var entities = level_base.entities_on_tile(5) # Red
			for entity in entities:
				if entity.name == "IotaHaver":
					level_base.level_progress = 3
					level_base.level_desc = descs[3]
					level_base.initiator.gate3.queue_free()
					return false
		3:
			var entities = level_base.entities_on_tile(4) # Green
			for entity in entities:
				if entity == level_base.player.entity:
					return true
	return false # Default false, if not valid for match