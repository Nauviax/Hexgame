# External Hub 2 Initiator
static func initiate(level_base):
	# Create a sample hex for player, and set as sb slot 1
	# Sample hex will get the entity player is looking at, and try to enter it.
	var hex_strings = ["1lLl", "2LL", "3lLl", "4sL", "5srLlL", "6llL"]
	var hex = []
	for ii in hex_strings:
		hex.append(Pattern.new(ii))
	level_base.player.sb[0] = hex
	