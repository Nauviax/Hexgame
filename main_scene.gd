@tool
extends Node2D

# Test_map scene
@onready var test_map = preload("res://map/test_map.tscn")

# For now, just load the test_map scene.
func _ready():
	var map = test_map.instantiate()

    # Offset the map to the right by a few pixels (Was getting cut off)
	map.position.x += 10

	add_child(map)
