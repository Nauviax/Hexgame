# World script for world 0 (Main external world)

# Levels that this world contains
static var levels: Array = [
	[Vector2(-1000, -1000), "res://levels/island_1/external_hub_1/level.tscn"],
	[Vector2(1000, -1000), "res://levels/island_2/external_hub_2/level.tscn"]
]

# Backgroud theme for this world
static var theme: String = "Outside"

# World description to be shown in UI
static var desc: String = "Between levels. You can see other islands from here."