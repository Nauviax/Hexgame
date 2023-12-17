extends Node2D
class_name Player

# The Level_Control node (Level's parent) controls Global.player_control, which determines if the player recieves input.

# Information that all entities need (Player is a friendly (1) entity)
var entity: Entity = Entity.new("Player", 1, self)

# Player starting spellbook for this level. Format: [iota, iota, iota, ...]
@export var player_sb: Array = [[0.0, 1.0, 2.0, 3.0, 4.0], null, null, null]
# Current default spellbook has 4 slots, and starts with the above 0-4 array.
# This can be changed per level, using the inspector (@export)

# The player's look line
@onready var look_line: Line2D = $Look_Dir

# Prepare player object
func _ready():
	# Player character normally has 4 iota slots, and their spellbook can be read from but not written to externally.
	entity.set_spellbook(true, false, player_sb)

# Func for aiming player's look line (Taking in mouse position)
func set_look_dir(mouse_pos: Vector2):
	# Set the look line's end position to the mouse position
	look_line.points[1] = mouse_pos
	# Adjust entity look unit vector
	entity.look_dir = (mouse_pos - entity.pos).normalized()


# Player controls
func _input(event):
	# Player control enabled?
	if not Globals.player_control:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() == true:
			print("Player recognized R_click")
	if event is InputEventMouseMotion:
		# Set the look line's end position to the mouse position
		look_line.points[1] = to_local(event.position)
		# Adjust entity look unit vector
		entity.look_dir = (look_line.points[1] - position).normalized() # !!!!!!!!!! NOT LOCAL OR SOMETHING