extends StaticBody2D
class_name LevelHaver

@export var entity_name: String = "LevelHaver"
@onready var entity: Entity = Entity.new(entity_name, self)

# The level scene this haver loads
@export var level_scene: PackedScene = null

# Iota that this level contains.
# Despite being an array, only the first element is used. (Variant type can't be exported)
@export var level_iota = [null]
# This can be changed per level, using the inspector (@export)

# Iota that this level has. (Duplicated here to prevent reference issues, deep copy etc)
var iota

# Level_haver's iota is always private. It becomes readable once level is beaten.

# Init object
func _ready():
	iota = level_iota.duplicate(true)[0] # Deep copy, take first
	entity.killable = false
	entity.moveable = false

# Level getter
func get_level():
	return level_scene

# Iota getter
func get_iota():
	return iota

# No setter (Shouldn't ever change)