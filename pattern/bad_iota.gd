class_name Bad_Iota

# Characters to use when generating random string
static var characters = "#%&@"

# Error message this iota contains
var error_msg

# Constructor (Type is an ErrorMM enum, name is the pattern name. var1-4 see ErrorMM)
func _init(type: int, name: String, var1 = null, var2 = null, var3 = null, var4 = null):
	error_msg = ErrorMM.make(type, name, var1, var2, var3, var4)

# Display random gibberish, but with a link to the error message
func _to_string():
	var rand_chars = ""
	for ii in range(10):
		var random_index = randi() % characters.length()
		rand_chars += characters[random_index]
	return "[url=B" + error_msg + "]" + rand_chars + "[/url]"
