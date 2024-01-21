extends Node2D

# On pattern cast:
@onready var normal = $Normal
@onready var fail = $Fail
@onready var spell = $Spell
@onready var hermes = $Hermes
@onready var thoth = $Thoth

func play_normal():
	normal.play()

func play_fail():
	fail.play()

func play_spell():
	spell.play()

func play_hermes():
	hermes.play()

func play_thoth():
	thoth.play()

# On segment connect: (Also on spellbook scroll)
@onready var segment = $AddSeg

func play_segment():
	segment.play()

# Ambience: (Auto-play currently)
@onready var aambience = $Ambience


