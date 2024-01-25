extends Area2D
# Note about level_in_world collision layer: (4)
#   Currently uses the player's spike checker to detect entering areas

# Simply holds a string reference to the levels filepath
var level_path

# Display name for this level (Does not need to match anything)
var level_name

# Reference to this node's pointer
var pointer

# On _ready, set the pointer's text to the level's name
func _ready():
	pointer = $Pointer
	pointer.get_node("Label").text = level_name