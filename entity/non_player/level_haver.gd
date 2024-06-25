extends StaticBody2D
class_name Level_Haver

@export var entity_name: String = "Level Haver"
@onready var entity: Entity = Entity.new(entity_name, self)

# The level scene this haver loads
@export var level_scene: PackedScene = null

# Iota that this level contains.
# Despite being an array, only the first element is used. (Array, as Variant type can't be exported in editor)
@export var level_iota: Array = [null]
# This can be changed per level, using the inspector (@export)

# Iota that this level has. (Duplicated here to prevent reference issues, deep copy etc)
var iota: Variant

# Level_haver's iota is always private. It becomes readable once level is beaten.

# Label to display name on hover
@onready var text_label: Label = $TextPos/Text

# Init object
func _ready() -> void:
	iota = level_iota.duplicate(true)[0] # Deep copy, take first
	entity.killable = false
	entity.moveable = false
	text_label.text = entity_name

# Level getter
func get_level() -> PackedScene:
	return level_scene

# Iota getter
func get_iota() -> Variant:
	return iota

# No setter (Shouldn't ever change)

# Control text visibility with mouse
func _on_mouse_entered() -> void:
	text_label.visible = true

func _on_mouse_exited() -> void:
	text_label.visible = false