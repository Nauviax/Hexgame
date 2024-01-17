# Reveal Iota Initiator
static var iota # Goal value to reveal for this level
static func initiate(level_base):
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver":
			# Set entity.sb[0] to random rounded float
			entity.sb[0] = float(randi_range(0, 99))
			iota = entity.sb[0] # Save iota
			break # Just one IotaHaver on level