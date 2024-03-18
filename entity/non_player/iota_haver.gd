extends StaticBody2D

# Information that all entities need
@export var entity_name: String = "IotaHaver"
@onready var entity: Entity = Entity.new(entity_name, self)

# Iota that this haver haves.
# Despite being an array, only the first element is used. (Variant type can't be exported)
@export var haver_iota = [null]
# This can be changed per level, using the inspector (@export)

# Bool for if entity sb can be written to externally
@export var writeable: bool = true

# Iota that this haver haves. (Duplicated here to prevent reference issues, deep copy etc)
var iota

# Label to display name on hover
@onready var text_label = $TextPos/Text

# Init object
func _ready():
	entity.readable = true # Always readable
	entity.writeable = writeable
	iota = haver_iota.duplicate(true)[0] # Deep copy of haver_iota, then save first item
	text_label.text = entity_name

# Iota getter
func get_iota():
	return iota

# Iota setter (entity obj will confirm writeability)
func set_iota(new_iota):
	iota = new_iota
	
# Control text visibility with mouse
func _on_mouse_entered():
	text_label.visible = true

func _on_mouse_exited():
	text_label.visible = false