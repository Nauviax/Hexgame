extends StaticBody2D

# Information that all entities need
@export var entity_name: String = "IotaHaver"
@onready var entity: Entity = Entity.new(entity_name, self)

# Starting spellbook for this entity. Format: [iota, iota, iota, ...]
@export var sb: Array = [42.0]
# This can be changed per level, using the inspector (@export)

# Bool for if entity sb can be read from externally
@export var sb_read: bool = true
# Bool for if entity sb can be written to externally
@export var sb_write: bool = true

# Looking dir set (Should be normalized)
@export var look_dir: Vector2 = Vector2(-1.0, 0.0)

# Init object
func _ready():
	entity.set_spellbook(sb_read, sb_write, sb.duplicate(true))
	entity.look_dir = look_dir.normalized()