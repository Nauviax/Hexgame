# Test Level Initiator
static func initiate(level_base: Level_Base) -> void:
	var rnd: RandomNumberGenerator = level_base.rnd
	var entities: Array = level_base.entities
	for entity: Entity in entities:
		if entity.name == "IotaHaver_Rand":
			# Set haver iota to random rounded float between 0 and 99
			entity.node.iota = float(rnd.randi_range(0, 99))
