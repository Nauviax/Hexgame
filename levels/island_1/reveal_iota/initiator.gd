# Reveal Iota Initiator
static var iota: Variant # Goal value to reveal for this level
static func initiate(level_base: Level_Base) -> void:
	var rnd: RandomNumberGenerator = level_base.rnd
	var entities: Array = level_base.entities
	for entity: Entity in entities:
		if entity.name == "IotaHaver":
			# Set iota haver to random rounded float
			entity.node.iota = float(rnd.randi_range(0, 99))
			iota = entity.node.iota # Save iota
			break # Just one IotaHaver on level
