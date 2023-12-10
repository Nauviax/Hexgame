@tool
extends Node2D
# Test map is for debugging. Not intended to be in final game.

# Stores information about the map. Required for all maps.
var map_info

# Generate base map info
func _ready():
	var player = Entity.new("Player", Vector2(0, 0), 1)
	# Player entity is named "Player", starts at (0, 0), and is on team 1 (Friendly)
	player.set_spellbook(true, false, [[0.0,1.0,2.0,3.0,4.0], null, null, null])
	# Player character has 4 iota slots, and their spellbook can be read from but not written to externally.
	# Player's initial spellbook has a list iota for testing
	map_info = Map_Info.new(player) # Create map info, which includes hexlogic node
	add_child(map_info.hexlogic) # Important to add this node to the scene tree


	# Adding some dummy entities
	var enemy = Entity.new("Enemy", Vector2(1, 0), -1)
	var enemyPrivate = Entity.new("EnemyPrivate", Vector2(0, -2), -1)
	enemyPrivate.set_spellbook(false, false, [64.0]) # Private enemy can't be read/write externally, for testing.
	var enemyFar = Entity.new("EnemyFar", Vector2(20, 20), -1)
	var neutral = Entity.new("Neutral", Vector2(0, 3), 0)
	neutral.set_spellbook(true, true, [420.0]) # Readable and writable iota, init 420
	var friendly = Entity.new("Friendly", Vector2(0, -3), 1)

	# Add entities to map info
	map_info.entities.push_back(enemy)
	map_info.entities.push_back(enemyPrivate)
	map_info.entities.push_back(enemyFar)
	map_info.entities.push_back(neutral)
	map_info.entities.push_back(friendly)


