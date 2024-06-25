extends Sprite2D

# This script will fade the pointer in, then fade it out once the below var is flipped
var fade_out: bool = false
var moved: bool = false # When pointer begins fading out, it will move to position itself correctly around player

# When created, hide the sprite
func _ready() -> void:
	modulate.a = 0

# Fade the pointer in and out
func _process(_delta: float) -> void:
	if fade_out:
		if not moved:
			position = position.normalized() * -150 # 150 pixels from player, in the direction of the pointer
			moved = true
		modulate.a -= 0.01
		if modulate.a <= 0:
			queue_free()
	else:
		modulate.a += 0.01
