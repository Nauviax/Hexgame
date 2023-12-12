class_name Level_Info # Holds core information about any given level. All levels should have a MapInfo object

# List of entities in the level
var entities

# Player character for the level
var player

# Constructor
func _init(player):
	self.player = player
	self.entities = [player] # First entity in level: Player (yay)
	# Add entities to this list as they are created (In level not here)
