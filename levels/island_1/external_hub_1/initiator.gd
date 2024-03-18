# External Hub 1 Initiator
static func initiate(level_base):
	# Create starting hexes for player, and set as sb slot 1 and 2
	# If player spellbook is not empty, do not overwrite it. (Run on first enter only)
	if level_base.player.sb != [null, null, null, null, null, null, null, null, null]:
		return
	# Sample hex will get the entity player is looking at, and try to enter it.
	var hex_strings = ["1lLl", "2LL", "1lLl", "2sL", "2srLlL", "6llL"]
	var hex = []
	for ii in hex_strings:
		hex.append(Pattern.new(ii))
	level_base.player.sb[0] = hex
	# Next hex will give the caster levitation, for quick flight
	hex_strings = ["1lLl", "5lllllLssLsLsR"]
	hex = []
	for ii in hex_strings:
		hex.append(Pattern.new(ii))
	level_base.player.sb[1] = hex
	
