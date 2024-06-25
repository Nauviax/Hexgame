extends Area2D

# Objects do not have an entity object, as they are simpler than an entity.

@export var obj_name: String = "Sign"

# To be displayed when the player enters it's area
@export_multiline var text: String = "This is a sign. It has some text on it."

# Label to display the text on
@onready var text_label: Label = $TextPos/Text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_label.text = text
	text_label.visible = false

# Control Visibility on player enter
var player_near: bool = false # Prevent mouse_exit from always hiding the label

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		text_label.visible = true
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		text_label.visible = false
		player_near = false

# Control Visibility with mouse, higher priority than body
func _on_mouse_entered() -> void:
	text_label.visible = true

func _on_mouse_exited() -> void:
	text_label.visible = player_near # Only hide if player is not near
