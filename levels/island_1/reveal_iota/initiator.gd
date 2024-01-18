# Reveal Iota Initiator
static var iota # Goal value to reveal for this level
static func initiate(level_base):
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver":
			# Set iota haver to random rounded float
			entity.node.iota = float(randi_range(0, 99))
			iota = entity.node.iota # Save iota
			break # Just one IotaHaver on level
