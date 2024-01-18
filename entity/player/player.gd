extends CharacterBody2D
class_name Player

# The Level_Control node (Level's parent) controls Global.player_control, which determines if the player recieves input.

# Information that all entities need
var entity: Entity = Entity.new("Player", self)

# Reference to the player's sentinel sprite (Pos and visibility controlled by entity)
@export var sentinel: Node2D

# Particle emitter references
@onready var poofer_pgen = $Poofer
@onready var trailer_pgen = $Trailer

# Viewport/camera references
@onready var viewport: Viewport = get_viewport()
#@onready var camera: Camera2D = $Camera2D

# Player starting spellbook for this level. Format: [iota, iota, iota, ...]
@export var player_sb: Array = [[0.0, 1.0, 2.0, 3.0, 4.0], null, null, null]
# Current default spellbook has 4 slots, and starts with the above 0-4 array.
# This can be changed per level, using the inspector (@export)

# Variables for player movement
var speed = 1024
var bounce = 0.25 # Velocity preserved on collision (0.1 means 10% in collision direction)
var friction = 0.05 # Pull towards 0 when no input
var tile_gravity = 10 # Pull strength of tiles (When slow enough)
var tile_gravity_max_vel = 75 # Maximum velocity before tile gravity stops
var acceleration = 0.015
var tile_snap = Vector2(Entity.FAKE_SCALE, Entity.FAKE_SCALE) # Should equal grid scale, so player snaps to grid.
var fly_chargeup = 0 # Charge to begin flying. 0 = not flying, 1-49 = charging, 50+ = flying (Flying has different movement)
var flying = false # Whether the player is flying or not. True once charge reaches 50, but only false when charge reaches 0 again. (Player gains control earlier!)
var fly_turnspeed = 0.075 # How fast the player turns while flying (Should be less than 1)

# Respawn point, should player ever become out of bounds (Set to initial position)
# Level_Base will move the player here if they aren't on a tile, checked every second.
@onready var respawn_point: Vector2 = position

# The player's look line
@onready var look_line: Line2D = $Look_Dir

# Prepare player object
func _ready():
	# Player character normally has 4 iota slots, and their spellbook can be read from but not written to externally.
	entity.set_spellbook(true, false, player_sb.duplicate(true)) # Duplicate, or it won't reset with level
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
	if Input.is_action_pressed("fly"):
		# Flight chargeup control
		# !!! Check is_floating later !!!
		if fly_chargeup < 50:
			fly_chargeup += 1
		elif not flying and fly_chargeup == 50:
			flying = true
			poofer_pgen.restart() # Fix poof particles sometimes not poofing on next takeoff
			trailer_pgen.emitting = true # Start trail particles
	else: # Handle decharging
		if fly_chargeup > 1:
			fly_chargeup -= 1
		elif fly_chargeup == 1: # If charge about to end, stop flying
			fly_chargeup -= 1
			flying = false
			trailer_pgen.emitting = false # Stop trail particles

	# Movement
	if fly_chargeup < 30 and not Input.is_action_pressed("fly"): # Normal, grounded movement
		if input_dir != Vector2.ZERO:
			# Lerp towards input direction
			velocity = lerp(velocity, input_dir.normalized() * speed, acceleration / 2 if entity.is_floating else acceleration)
		else:
			# Apply friction
			velocity = lerp(velocity, Vector2.ZERO, friction / 4 if entity.is_floating else friction)
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
	else: # Flight mechanics
		# If still charging, just apply friction (though stronger than normal)
		if fly_chargeup < 50:
			velocity = lerp(velocity, Vector2.ZERO, friction * 2)
			var collision = move_and_collide(velocity * delta)
			if collision:
				# Bounce off of collision
				var col_norm = collision.get_normal()
				# Bounce only horizontally or vertically, as most/all collisions are with tiles.
				if abs(col_norm.x) > abs(col_norm.y):
					velocity.x *= -bounce
					# Step away based on depth in collision
					position.x += collision.get_depth()
				else:
					velocity.y *= -bounce
					# Step away based on depth in collision
					position.y += collision.get_depth()
		# If finished charging, apply flight movement instead
		else:
			if input_dir.x != 0 or input_dir.y != 0:
				var angle_dif = velocity.angle_to(input_dir)
				var new_angle = velocity.angle() + angle_dif * fly_turnspeed
				velocity = Vector2.from_angle(new_angle) * speed
			position += velocity * delta # Ignore collisions, as we're flying

	# Player aiming controls
	set_look_dir(get_local_mouse_position())

# Player cast controls (right click) are located in main_scene, as it requires access to hexecutor.

# Handle collision with spikes
func _on_spike_checker_body_entered(_body):
	# If floating, ignore
	if not entity.is_floating:
		# Invert velocity and multiply
		velocity *= -(1 + bounce)

func _on_spike_checker_body_exited(_body):
	# Clear floating
	entity.is_floating = false
