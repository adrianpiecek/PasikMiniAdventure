extends Path2D

@export var speed: float = 50.0
@export var sink_amount: float = 5.0
@export var sink_duration: float = 0.2
@export var fall_after_landing: bool = true
@export var fall_delay: float = 1.0

@onready var follow: PathFollow2D = $PathFollow2D
@onready var platform: Node2D = $PathFollow2D/Platform
@onready var sprite: AnimatedSprite2D = $PathFollow2D/Platform/AnimatedSprite2D

var original_y: float
var sinking := false
var falling := false

func _ready():
	original_y = platform.position.y
	set_process(true)
	platform.connect("player_landed", Callable(self, "_on_platform_player_landed"))
	if fall_after_landing:
		sprite.play("falling")
	else:
		sprite.play("not_falling")
		


func _process(delta):
	if not falling:
		follow.progress += speed * delta

func start_fall():
	falling = true

	var fall_distance = 300
	var tween = get_tree().create_tween()
	tween.tween_property(platform, "position:y", platform.position.y + fall_distance, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished

	# Ukryj platformę i wyłącz kolizję
	platform.visible = false
	follow.progress = 0.0
	var collision_shape = platform.get_node("CollisionShape2D")
	if collision_shape:
		collision_shape.disabled = true

	await get_tree().create_timer(2.0).timeout  # czas "odrodzenia"

	# Przesuń nad oryginalną pozycję
	platform.position.y = original_y - fall_distance
	platform.visible = true

	# Odradzanie z góry z tweenem
	var tween_up = get_tree().create_tween()
	tween_up.tween_property(platform, "position:y", original_y, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween_up.finished

	# Przywróć kolizję
	if collision_shape:
		collision_shape.disabled = false

	falling = false


func _on_platform_player_landed():
	if sinking or falling:
		return
	sinking = true
	# animacja ugięcia
	var tween = get_tree().create_tween()
	tween.tween_property(platform, "position:y", original_y + sink_amount, sink_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(platform, "position:y", original_y, sink_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_sink_finished"))
	
	if fall_after_landing:
		await get_tree().create_timer(fall_delay).timeout
		start_fall()
		
func _on_sink_finished():
	sinking = false
