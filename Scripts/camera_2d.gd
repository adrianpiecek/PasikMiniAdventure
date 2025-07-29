extends Camera2D

var shake_amount: float = 5.0
var shake_time: float = 0.1
var shake_timer: float = 0.0

func start_screen_shake():
	shake_timer = shake_time

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	else:
		offset = Vector2.ZERO
