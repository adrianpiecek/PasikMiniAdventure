extends Node

var music_player: AudioStreamPlayer
var fade_speed := 1.0
var is_fading_out := false
var is_fading_in := false
var global_volume_db := 0.0 


func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"  # upewnij się, że taki bus istnieje

func play_music(stream: AudioStream, fade_in_time := 1.0):
	music_player.stream = stream
	music_player.volume_db = -80
	music_player.play()
	fade_speed = 80.0 / fade_in_time
	is_fading_in = true
	is_fading_out = false

func stop_music(fade_out_time := 1.0):
	fade_speed = 80.0 / fade_out_time
	is_fading_out = true
	is_fading_in = false

func _process(delta):
	if is_fading_in:
		music_player.volume_db += fade_speed * delta
		if music_player.volume_db >= global_volume_db:
			music_player.volume_db = global_volume_db
			is_fading_in = false
	elif is_fading_out:
		music_player.volume_db -= fade_speed * delta
		if music_player.volume_db <= -80:
			music_player.stop()
			is_fading_out = false
	else:
		music_player.volume_db = global_volume_db

func set_music_volume(percent: float):
	# percent: 0.0–1.0
	global_volume_db = lerp(-80.0, 0.0, clamp(percent, 0.0, 1.0))

func get_music_volume_percent() -> float:
	return inverse_lerp(-80.0, 0.0, global_volume_db)
