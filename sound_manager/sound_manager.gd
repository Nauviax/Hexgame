extends Node2D

# On pattern cast:
@onready var normal: AudioStreamPlayer = $Normal
@onready var fail: AudioStreamPlayer = $Fail
@onready var spell: AudioStreamPlayer = $Spell
@onready var hermes: AudioStreamPlayer = $Hermes
@onready var thoth: AudioStreamPlayer = $Thoth

func play_normal() -> void:
	normal.play()

func play_fail() -> void:
	fail.play()

func play_spell() -> void:
	spell.play()

func play_hermes() -> void:
	hermes.play()

func play_thoth() -> void:
	thoth.play()

# On segment connect: (Also on spellbook scroll)
@onready var segment: AudioStreamPlayer = $AddSeg

func play_segment() -> void:
	segment.play()

# Ambience: (Auto-play currently)
@onready var ambience: AudioStreamPlayer = $Ambience


