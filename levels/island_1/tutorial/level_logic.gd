# Tutorial level_logic

static var level_progress = 0 # Keeps track of how many steps the player has completed in the level
static func validate(level_base):
	match level_progress:
		0:
			if level_base.revealed_iota is Entity and level_base.revealed_iota == level_base.player.entity:
				level_progress = 1
				level_base.initiator.gate1.queue_free()
				return false
		1:
			if level_base.revealed_iota is float and level_base.revealed_iota == level_base.initiator.iota:
				level_progress = 2
				level_base.initiator.gate2.queue_free()
				return false
		2:
			var entities = level_base.entities_on_tile(5) # Red
			for entity in entities:
				if entity.name == "IotaHaver":
					level_progress = 3
					level_base.initiator.gate3.queue_free()
					return false
		3:
			var entities = level_base.entities_on_tile(4) # Green
			for entity in entities:
				if entity == level_base.player.entity:
					return true
	return false # Default false, if not valid for match