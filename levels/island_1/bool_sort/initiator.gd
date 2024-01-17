# Bool Sort Initiator
static func initiate(level_base):
	var entities = level_base.entities
	var true_count = 0
	var iota_havers = []
	for entity in entities:
		if entity.name == "IotaHaver":
			iota_havers.append(entity) # For emergency set true 
			# Set entity.sb[0] to true or false randomly
			entity.sb[0] = randi_range(0, 1) == 1
			if entity.sb[0]:
				true_count += 1
	# If there are no true entities, or all entities are true, fix.
	if true_count == 0 or true_count == entities.size():
		var iota_haver = iota_havers[randi_range(0, iota_havers.size() - 1)]
		iota_haver.sb[0] = true_count == 0 # True if there are no true entities, false if all entities are true