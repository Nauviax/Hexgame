# Tutorial Initiator
static var iota # Goal value to reveal for this level
static func initiate(level_base):
	var rnd = level_base.rnd
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver":
			# Set iota haver to random rounded float
			entity.node.iota = float(rnd.randi_range(0, 99))
			iota = entity.node.iota # Save iota
			break # Just one IotaHaver on level
