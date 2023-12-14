extends Node2D

# On pattern cast:
@onready var normal = $Normal
@onready var fail = $Fail

func play_normal():
	normal.play()

func play_fail():
	fail.play()

# On segment connect:
@onready var segment = $Add_Seg

func play_segment():
	segment.play()

# Ambience: (Auto-play currently)
@onready var aambience = $Ambience


