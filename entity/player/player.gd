extends CharacterBody2D
class_name Player

# The Level_Control node (Level's parent) controls Global.player_control, which determines if the player recieves input.

# Information that all entities need (Player is a friendly (1) entity)
var entity: Entity = Entity.new("Player", 1, self)

# Player starting spellbook for this level. Format: [iota, iota, iota, ...]
@export var player_sb: Array = [[0.0, 1.0, 2.0, 3.0, 4.0], null, null, null]
# Current default spellbook has 4 slots, and starts with the above 0-4 array.
# This can be changed per level, using the inspector (@export)

# Variables for player movement
var speed = 1024
var bounce = 0.1 # Velocity preserved on collision (0.1 means 10% in collision direction)
var friction = 0.05 # Pull towards 0 when no input
var tile_gravity = 10 # Pull strength of tiles (When slow enough)
var tile_gravity_max_vel = 75 # Maximum velocity before tile gravity stops
var acceleration = 0.015
var tile_snap = Vector2(Entity.FAKE_SCALE, Entity.FAKE_SCALE)

# The player's look line
@onready var look_line: Line2D = $Look_Dir

# Prepare player object
func _ready():
	# Player character normally has 4 iota slots, and their spellbook can be read from but not written to externally.
	entity.set_spellbook(true, false, player_sb)
	entity.look_dir = Vector2(0.0, -1.0) # Init just look up

# Func for aiming player's look line (Taking in mouse position)
func set_look_dir(mouse_pos: Vector2):
	# Set the look line's end position to the mouse position
	look_line.points[1] = mouse_pos
	# Adjust entity look unit vector
	entity.look_dir = mouse_pos.normalized()

# Player movement controls
func _physics_process(delta):
	if not Globals.player_control:
		return # Player control required

	# Keyboard input
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	# Movement
	if input_dir != Vector2.ZERO:
		# Lerp towards input direction
		velocity = lerp(velocity, input_dir.normalized() * speed, acceleration)
	else:
		# Apply friction
		velocity = lerp(velocity, Vector2.ZERO, friction)
		var vel_len = velocity.length()
		# If close enough and slow enough, snap to grid
		var tile_center = position.snapped(tile_snap)
		var tile_dir = tile_center - position
		if tile_dir.length() < 1 and vel_len < 25:
			position = tile_center
			velocity = Vector2.ZERO
		# Otherwise, apply velocity towards nearest tile center
		elif vel_len < tile_gravity_max_vel:
			velocity += tile_dir.normalized() * tile_gravity
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Bounce off of collision
		var col_norm = collision.get_normal()
		# Bounce only horizontally or vertically, as most/all collisions are with tiles.
		if abs(col_norm.x) > abs(col_norm.y):
			velocity.x *= -bounce
		else:
			velocity.y *= -bounce


	# Player aiming controls
	set_look_dir(to_local(get_viewport().get_mouse_position()))