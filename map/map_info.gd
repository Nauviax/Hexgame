@tool
class_name Map_Info # Holds core information about any given map. All maps should have a MapInfo object

# Reference to Hexlogic scene
var Hexlogic = preload("res://hexlogic/hexlogic.tscn")

# Hexlogic reference. This also contains information about the player/caster.
var hexlogic

# List of entities in the map
var entities

# Constructor. Also sets up the hexlogic scene.
# Remember to add hexlogic to the scene tree after instantiating. (Not in map_info)
func _init(player):
	hexlogic = Hexlogic.instantiate()
	hexlogic.init(player, self)
	self.entities = [player] # First entity in map: Player (yay)
	# Add entities to this list as they are created
