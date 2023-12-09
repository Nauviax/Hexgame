class_name Entity

# Info regarding this entity, set on _init()
var disp_name # Display name for entity
var position # (0.0, 0.0)
var looking_dir # (1.0, 0.0), normalized vector
var velocity # (0.0, 0.0), Speed is magnitude, direction would be normalized vector

func _init(name = "No_Name", pos = Vector2(0, 0), look = Vector2(1, 0), vel = Vector2(0, 0)):
	disp_name = name
	position = pos
	looking_dir = look
	velocity = vel

func _to_string():
	return "Entity: " + disp_name
