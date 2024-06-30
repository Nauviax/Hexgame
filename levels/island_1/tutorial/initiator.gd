# Tutorial Initiator
static var iota: Variant # Goal value to reveal for this level
static var gate1: Node2D # Gates stored here for easy reference in level_logic
static var gate2: Node2D
static var gate3: Node2D
static func initiate(level_base: Level_Base) -> void:
	var rnd: RandomNumberGenerator = level_base.rnd
	var entities: Array = level_base.entities
	for entity: Entity in entities:
		if entity.name == "IotaHaver":
			# Set iota haver to random rounded float
			entity.node.iota = float(rnd.randi_range(0, 99))
			iota = entity.node.iota # Save iota
			break # Just one IotaHaver on level
	var objects: Array = level_base.objects
	for object: Node2D in objects:
		match object.obj_name:
			"Gate1":
				gate1 = object
			"Gate2":
				gate2 = object
			"Gate3":
				gate3 = object 
