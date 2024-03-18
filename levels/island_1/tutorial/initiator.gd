# Tutorial Initiator
static var iota # Goal value to reveal for this level
static var gate1 # Gates stored here for easy reference in level_logic
static var gate2
static var gate3
static func initiate(level_base):
	var rnd = level_base.rnd
	var entities = level_base.entities
	for entity in entities:
		if entity.name == "IotaHaver":
			# Set iota haver to random rounded float
			entity.node.iota = float(rnd.randi_range(0, 99))
			iota = entity.node.iota # Save iota
			break # Just one IotaHaver on level
	var objects = level_base.objects
	for object in objects:
		match object.obj_name:
			"Gate1":
				gate1 = object
			"Gate2":
				gate2 = object
			"Gate3":
				gate3 = object 
