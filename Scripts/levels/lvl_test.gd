extends Node2D

func _ready() -> void:
	Music.set_music_volume(0.75)
	Music.play_music(load("res://Assets/music/Clement Panchout - Sweet 70s.wav"), 1.5)
