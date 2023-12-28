extends StaticBody2D
class_name LevelHaver

@export var entity_name: String = "LevelHaver"
@onready var entity: Entity = Entity.new(entity_name, self)

# The level scene this haver loads (This is stored in the entities ravenmind)
@export var level_scene: PackedScene = null

# Starting spellbook for this entity. Format: [iota, iota, iota, ...]
@export var sb: Array = [null]
# This can be changed per level, using the inspector (@export)

# Level_haver's spellbook is always private. It becomes readable once level is beaten.

# Looking dir set (Should be normalized)
@export var look_dir: Vector2 = Vector2(-1.0, 0.0)

# Init object
func _ready():
	entity.set_spellbook(false, false, sb.duplicate(true))
	entity.look_dir = look_dir.normalized()
	entity.ravenmind = level_scene