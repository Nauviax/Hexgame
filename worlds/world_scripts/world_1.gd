# World script for world 0 (Main external world)

# Levels that this world contains
# Format: [position, level path, display name]
static var levels: Array = [
	[Vector2(-1000, -1000), "res://levels/island_1/reveal_iota/level.tscn", "Reveal Iota"],
	[Vector2(1000, -1000), "res://levels/island_1/bool_sort/level.tscn", "Bool Sort"],
	[Vector2(-1000, 1000), "res://levels/island_1/test_level/level.tscn", "Test Level"],
]

# Backgroud theme for this world
static var theme: String = "inside"