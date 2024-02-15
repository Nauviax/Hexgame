# Reveal Iota Validator
static var desc = "Tutorial step 1: Reveal yourself by casting Mind's Reflection then Reveal."
static var step = -1 # Starts at -1 so next step is index 0 for steps list. Jank, but ehhhh
static var steps = [
	"Tutorial step 2: Reveal the iota contained in the entity in the next room.",
	"Tutorial step 3: Move the entity onto the red area past the spikes.",
	"Tutorial step 4: Finish on the green area by teleporting through the glass.",
]
static func validate(level_base):
	match step:
		-1:
			if level_base.revealed_iota is Entity and level_base.revealed_iota == level_base.player.entity:
				step = 0
				desc = steps[0]
				level_base.initiator.gate1.queue_free()
				return false
		0:
			if level_base.revealed_iota is float and level_base.revealed_iota == level_base.initiator.iota:
				step = 1
				desc = steps[1]
				level_base.initiator.gate2.queue_free()
				return false
		1:
			var entities = level_base.entities_on_tile(5) # Red
			for entity in entities:
				if entity.name == "IotaHaver":
					step = 2
					desc = steps[2]
					level_base.initiator.gate3.queue_free()
					return false
		2:
			var entities = level_base.entities_on_tile(4) # Green
			for entity in entities:
				if entity == level_base.player.entity:
					return true
	return false # Default false, if not valid for match