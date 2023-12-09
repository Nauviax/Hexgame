class_name Bad_Iota

# Characters to use when generating random string
var characters = "#%&@"

func _to_string():
	var result = ""
	for ii in range(10):
		var random_index = randi() % characters.length()
		result += characters[random_index]
	return result
