extends TextureRect

signal transition_finished

@export var duration: float = 0.5
@export var delay_before_restart: float = 0.01

var tween: Tween
var tween_intro: Tween

func _ready():
	set_anchors_preset(Control.PRESET_CENTER)
	call_deferred("_set_pivot_center")
	scale = Vector2(45, 45)
	if tween_intro:
		tween_intro.kill()
	show()
	tween_intro = get_tree().create_tween()
	tween_intro.tween_property(self, "scale", Vector2(0.1, 0.1), duration)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_intro.tween_callback(func ():
		hide()
	)

func _set_pivot_center():
	set_pivot_offset(size / 2)

func play_transition(callback_func: Callable = Callable()):
	scale = Vector2(0.1, 0.1)
	show()

	if tween:
		tween.kill()

	tween = get_tree().create_tween()

	# 1. Powiększanie rombu (zamykanie)
	tween.tween_property(self, "scale", Vector2(45, 45), duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# 2. Callback (np. restart poziomu) – kiedy ekran jest ZASŁONIĘTY
	if callback_func.is_valid():
		tween.tween_callback(callback_func)

	tween.tween_callback(func ():
		hide()
		emit_signal("transition_finished")
	)
