extends Area2D
# Note about level_in_world collision layer: (4)
#   Currently uses the player's spike checker to detect entering areas

# Simply holds a string reference to the levels filepath
var level_path

# Reference to this node's pointer
@onready var pointer = $Pointer