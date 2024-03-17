extends Area2D

# Objects do not have an entity object, as they are simpler than an entity.

@export var obj_name = "Sign"

# To be displayed when the player enters it's area
@export var text = "This is a sign. It has some text on it."

# Label to display the text on
@onready var text_label = $TextPos/Text

# Called when the node enters the scene tree for the first time.
func _ready():
	text_label.text = text
	text_label.visible = false

# Control Visibility
func _on_body_entered(_body:Node2D):
	text_label.visible = true

func _on_body_exited(_body:Node2D):
	text_label.visible = false
