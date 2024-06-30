# Bool Sort Initiator
static var true_count: int = 0
static func initiate(level_base: Level_Base) -> void:
	var rnd: RandomNumberGenerator = level_base.rnd
	var entities: Array = level_base.entities
	var iota_havers: Array = []
	for entity: Entity in entities:
		if entity.name == "IotaHaver":
			iota_havers.append(entity) # For emergency set true 
			# Set haver iota to true or false randomly
			entity.node.iota = rnd.randi_range(0, 1) == 1
			if entity.node.iota:
				true_count += 1
	# If there are no true entities, or all entities are true, fix.
	if true_count == 0 or true_count == entities.size():
		var iota_haver: Entity = iota_havers[rnd.randi_range(0, iota_havers.size() - 1)]
		iota_haver.node.iota = true_count == 0 # True if there are no true entities, false if all entities are true
		true_count += (1 if iota_haver.node.iota else -1) # Update true count
