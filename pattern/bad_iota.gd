class_name Bad_Iota

# Characters to use when generating random string
static var characters: String = "#%&@"

# Error message this iota contains
var error_msg: String

# Constructor (Type is an ErrorMM enum, name is the pattern name. var1-4 see ErrorMM)
func _init(type: int, name: String, var1: Variant = null, var2: Variant = null, var3: Variant = null, var4: Variant = null) -> void:
	error_msg = ErrorMM.make(type, name, var1, var2, var3, var4)

# Display random gibberish, but with a link to the error message
func _to_string() -> String:
	var rand_chars: String = ""
	for ii in range(10):
		var random_index: int = randi() % characters.length()
		rand_chars += characters[random_index]
	return "[url=E" + error_msg + "]" + rand_chars + "[/url]"
