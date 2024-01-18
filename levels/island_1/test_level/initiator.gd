# Test Level Initiator
static func initiate(level_base):
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver_Rand":
			# Set haver iota to random rounded float between 0 and 99
			entity.node.iota = float(randi_range(0, 99))
