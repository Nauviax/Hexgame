# Test Level Randomizer
static func randomize(level_base):
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver_Rand":
			# Set entity.sb[0] to random rounded float between 0 and 99
			entity.sb[0] = float(randi_range(0, 99))
