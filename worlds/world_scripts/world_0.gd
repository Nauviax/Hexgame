# World script for world 0 (Main external world)

# Levels that this world contains
# Format: [position, level path, display name]
static var levels: Array = [
	[Vector2(-1000, -1000), "res://levels/island_1/external_hub_1/level.tscn", "Island 1"],
	[Vector2(1000, -1000), "res://levels/island_2/external_hub_2/level.tscn", "Island 2"],
]

# Backgroud theme for this world
static var theme: String = "Outside"

# World description to be shown in UI
static var desc: String = "Between levels. You can see other islands from here."