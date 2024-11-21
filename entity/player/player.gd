extends CharacterBody2D
class_name Player

# The Level_Control node (Level's parent) controls Global.player_control, which determines if the player recieves input.

# Information that all entities need
var entity: Entity = Entity.new("Player", self)

# Reference to the player's sentinel sprite (Pos and visibility controlled by entity)
@export var sentinel: Node2D

# Various parts of the player, for reference
@onready var poofer_pgen: GPUParticles2D = $Poofer
@onready var pre_poofer_pgen: GPUParticles2D = $PrePoofer
@onready var trailer_pgen: GPUParticles2D = $Trailer
@onready var cast_cast_pgen: GPUParticles2D = $CastOnCast
@onready var cast_target_pgen: GPUParticles2D = $CastOnTarget
@onready var cast_trail_pgen: GPUParticles2D = $CastOnTrail
@onready var camera: Camera2D = $Camera2D
@onready var body: Node2D = $PlayerBody # Node that holds sprites
@onready var look_line: Line2D = $LookDir # Looking direction line
@onready var parallax_bg: CanvasLayer = $ParallaxBG# Background references
@onready var parallax_near: Sprite2D = parallax_bg.get_node("NearLayer")
@onready var parallax_far: Sprite2D = parallax_bg.get_node("FarLayer")

# Respawn point, should player ever become out of bounds (Set to initial position)
# Level_Base will move the player here if they aren't on a tile, checked every second.
@onready var respawn_point: Vector2 = position

# Player starting spellbook for this level. Format: [iota, iota, iota, ...]
@export var player_sb: Array = [null, null, null, null, null, null, null, null, null]
# Current default spellbook has 9 slots, all initially null. Size can change per-level, but isn't recommended.
# This can be changed per level, using the inspector (@export)

# Player hex-casting variables
var sb: Array
var sb_sel: int = 0
var sentinel_pos: Variant = null # Vector2 OR null, hence Variant type. Fake coords. (Preserved on grid clear) (Ensure sentinel node is moved when this changes)
var ravenmind: Variant = null # Iota (Not readable/writable by other entities, and lost on grid clear)

# Variable constants for player movement
const speed = 1024
const bounce = 0.50 # Velocity preserved on collision (0.1 means 10% in collision direction)
const friction_no_input = 0.15 # Pull towards 0 when no input
const friction_input = 0.02 # Pull towards 0 during player input
const tile_gravity = 15 # Pull strength of tiles (When slow enough)
const tile_gravity_max_vel = 75 # Maximum velocity before tile gravity stops
const acceleration = 0.030
var tile_snap: Vector2 = Vector2(Entity.FAKE_SCALE, Entity.FAKE_SCALE) # Should equal grid scale, so player snaps to grid.

# Variables for player flight
var fly_chargeup: int = 0 # Charge to begin flying. 0 = not flying, 1-49 = charging, 50+ = flying (Flying has different movement)
var can_fly: bool = false # Whether the player can start flying or not.
var flying: bool = false # Whether the player is flying or not. True once charge reaches 50, but only false when charge reaches 0 again. (Player gains control earlier!)
var stuck_flying: bool = false # If true, player can't stop flying. Used in world_view.
const fly_turnspeed: float = 0.075 # How fast the player turns while flying (Should be less than 1)

# Misc player variables
var freeze_look_dir: bool = false # Whether player look direction is following mouse, or frozen.


# Prepare player object
func _ready() -> void:
	# Player character normally has 9 iota slots, and their spellbook can be read from and written to externally.
	sb = player_sb.duplicate(true)
	entity.readable = true
	entity.writeable = true
	entity.killable = false

# Get the selected spellbook iota
func get_iota() -> Variant:
	return sb[sb_sel]

# Set selected page of spellbook to iota
func set_iota(new_iota: Variant) -> void:
	sb[sb_sel] = new_iota

# Increment spellbook.
func inc_sb() -> void:
	sb_sel = (sb_sel + 1) % sb.size()

# Decrement spellbook.
func dec_sb() -> void:
	sb_sel = (sb_sel - 1 + sb.size()) % sb.size()

# Set sentinel, and show/hide based on null status. Again, Variant type for Vector2 AND null
func set_sentinel(pos: Variant) -> void:
	sentinel_pos = pos
	if sentinel_pos == null:
		sentinel.visible = false
	else:
		sentinel.visible = true
		sentinel.position = sentinel_pos * Entity.FAKE_SCALE

# Player movement controls
func _physics_process(delta: float) -> void:
	# Regardless of player control, apply wind to background
	scroll_background(Vector2(1, 0))
	if not Globals.player_control:
		return # Player control required

	# Keyboard input
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if entity.is_levitating and can_fly and Input.is_action_pressed("fly"): # All flight conditions met
		# Flight chargeup control
		if  fly_chargeup < 50:
			fly_chargeup += 1
			camera.zoom -= Vector2(0.01, 0.01) # Zoom out while charging (Until 0.5, 0.5)
			body.scale += Vector2(0.01, 0.01) # Scale up visibly while charging (Until 1.5, 1.5)
			pre_poofer_pgen.emitting = true # Start pre-poofer particles
		elif not flying and fly_chargeup == 50:
			flying = true
			poofer_pgen.restart() # Fix poof particles sometimes not poofing on next takeoff
			trailer_pgen.emitting = true # Start trail particles
			pre_poofer_pgen.emitting = false # Stop pre-poofer particles
	elif not stuck_flying: # Handle decharging (Assuming not stuck flying)
		pre_poofer_pgen.emitting = false # Stop pre-poofer particles
		if fly_chargeup > 1:
			fly_chargeup -= 1
			camera.zoom += Vector2(0.01, 0.01) # Revert back to normal zoom
			body.scale -= Vector2(0.01, 0.01) # Revert back to normal scale
		elif fly_chargeup == 1: # If charge about to end, stop flying
			fly_chargeup -= 1
			camera.zoom = Vector2.ONE # Reset zoom
			body.scale = Vector2.ONE # Reset scale
			flying = false
			entity.is_levitating = false # Stop levitating
			trailer_pgen.emitting = false # Stop trail particles

	# Movement
	var initial_pos: Vector2 = position # Used to scroll background based on movement
	if fly_chargeup < 30 and not Input.is_action_pressed("fly"): # Normal, grounded movement
		if input_dir != Vector2.ZERO:
			# Apply friction_input if not levitating
			if not entity.is_levitating:
				velocity = lerp(velocity, Vector2.ZERO, friction_input)
			# Lerp towards input direction
			velocity = lerp(velocity, input_dir.normalized() * speed, acceleration / 2 if entity.is_levitating else acceleration)
		else:
			# Apply friction_no_input
			velocity = lerp(velocity, Vector2.ZERO, friction_no_input / 4 if entity.is_levitating else friction_no_input)
			var vel_len: float = velocity.length()
			# If close enough and slow enough, snap to grid
			var tile_centre: Vector2 = position.snapped(tile_snap)
			var tile_dir: Vector2 = tile_centre - position
			if tile_dir.length() < 1 and vel_len < 25:
				position = tile_centre
				velocity = Vector2.ZERO
			# Otherwise, apply velocity towards nearest tile centre
			elif vel_len < tile_gravity_max_vel:
				velocity += tile_dir.normalized() * tile_gravity
		var collision: KinematicCollision2D = move_and_collide(velocity * delta)
		if collision:
			# Bounce off of collision
			var col_norm: Vector2 = collision.get_normal()
			# Bounce only horizontally or vertically, as most/all collisions are with tiles.
			if abs(col_norm.x) > abs(col_norm.y):
				velocity.x *= -bounce
			else:
				velocity.y *= -bounce
	else: # Flight mechanics
		# If still charging, just apply friction_no_input (though stronger than normal)
		# This means holding fly while not levitating will effectively act as a brake for normal player movement.
		if fly_chargeup < 50:
			velocity = lerp(velocity, Vector2.ZERO, friction_no_input * 2)
			var collision: KinematicCollision2D = move_and_collide(velocity * delta)
			if collision:
				# Bounce only horizontally or vertically, as most/all collisions are with tiles.
				var col_norm: Vector2 = collision.get_normal()
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
				var angle_dif: float = velocity.angle_to(input_dir)
				var new_angle: float = velocity.angle() + angle_dif * fly_turnspeed
				velocity = Vector2.from_angle(new_angle) * speed
			position += velocity * delta # Ignore collisions, as we're flying
	
	# Scroll background based on new position
	scroll_background(position - initial_pos)

	# Player aiming controls
	set_look_dir(get_local_mouse_position())

# Func for aiming player's look line (Taking in mouse position)
func set_look_dir(mouse_pos: Vector2) -> void:
	# Check if able to control look direction
	if freeze_look_dir:
		return
	# Set the look line's end position to the mouse position
	look_line.points[1] = mouse_pos
	# Adjust entity look unit vector
	entity.look_dir = mouse_pos.normalized()

# Player mouse input controls
func _input(event: InputEvent) -> void:
	if not Globals.player_control:
		return # Player control required
	if event is InputEventMouseButton:
		# If left click, freeze look direction
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			freeze_look_dir = !freeze_look_dir

# Player cast controls (right click) are located in main_scene, as it requires access to hexecutor.

# Player cast particle controls (Called from hexecutor or a pattern exe normally)
# Cast type takes an int, 0 for normal, 1 for fail, 2 for meta
func particle_cast(cast_type: int) -> void:
	var cast_color: Color
	match cast_type:
		0:
			cast_color = Color(0.9, 0.8, 1.0) # Light purple ish
		1:
			cast_color = Color(1.0, 0.6, 0.6) # Red ish
		2:
			cast_color = Color(1.0, 1.0, 0.4) # Yellow ish
	cast_cast_pgen.process_material.color = cast_color # !!! Not working?
	cast_cast_pgen.restart() # Restart so that new particles are shown

# Vector2 inputs are in REAL coordinates, and relative to level NOT player.
func particle_target(target_pos: Vector2) -> void:
	cast_target_pgen.position = target_pos - position
	cast_target_pgen.restart()
		
func particle_trail(trail_pos: Vector2, trail_vect: Vector2) -> void: 
	# Set pos
	cast_trail_pgen.position = trail_pos - position
	# Set rotation and scale to line up with trail_vect
	var pro_mat: Material = cast_trail_pgen.process_material
	var v_length: float = trail_vect.length() / 2 # Half length as emission shape expands in both directions (Annoying)
	pro_mat.emission_shape_scale.x = v_length
	pro_mat.emission_shape_offset.x = v_length - (Entity.FAKE_SCALE / 2) # Offset by a half tile, as particles move forwards anyway.
	cast_trail_pgen.amount = int(v_length / 4)
	var v_angle: float = trail_vect.angle()
	cast_trail_pgen.rotation = v_angle
	pro_mat.angle_min = v_angle * -57.296 # Convert to degrees
	pro_mat.angle_max = pro_mat.angle_min
	# Restart
	cast_trail_pgen.restart()

# Clear targeting casting particles. Normally called when entering a level, to prevent weird particle positions on return.
func particle_clear_targets() -> void:
	cast_target_pgen.emitting = false
	cast_trail_pgen.emitting = false

# Set background theme
# Options: "Inside", "Outside"
func set_background_theme(theme: String) -> void:
	# Set background theme 
	parallax_near.texture = load("res://resources/parallax/" + theme + "_near.png")
	parallax_far.texture = load("res://resources/parallax/" + theme + "_far.png")

# Scroll background by given amount
func scroll_background(amount: Vector2) -> void:
	var mod: int = 2 * parallax_near.texture.get_width() # So scroll can loop without jumping
	var relative_amnt: Vector2 = -amount / 4
	parallax_near.position.x = fmod(parallax_near.position.x + relative_amnt.x, mod)
	parallax_near.position.y = fmod(parallax_near.position.y + relative_amnt.y, mod)
	relative_amnt /= 2
	parallax_far.position.x = fmod(parallax_far.position.x + relative_amnt.x, mod)
	parallax_far.position.y = fmod(parallax_far.position.y + relative_amnt.y, mod)

# Handle collision with spikes (Importantly, clear levitating when exiting)
func _on_spike_checker_body_entered(_body: Node2D) -> void:
	# If levitating, ignore
	if not entity.is_levitating:
		# Invert velocity, and apply both a percentage and flat bonus to velocity. (Flat, so 0 velocity players can't enter spikes)
		velocity *= -1.2 # Launch away faster than impact
		# Add the velocity as a normalised vector to itself, acting as a small flat bonus. This way the spikes still have an effect at low speeds.
		velocity += velocity.normalized() * 100


func _on_spike_checker_body_exited(_body: Node2D) -> void:
	# Clear levitating
	if not flying: # Don't clear levitating if flying
		entity.is_levitating = false
