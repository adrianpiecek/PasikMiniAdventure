extends Area2D

@export var bounce_strength: float = 800.0  # Siła wyrzutu w górę
@export var cooldown_time: float = 0.5      # Czas odnowienia trampoliny

@onready var animated_sprite = $"../AnimatedSprite2D"
@onready var cooldown_timer = $CooldownTimer
@onready var bounce_sound = $"../BounceSound"

var can_bounce = true

func _ready():
	# Ustaw domyślną animację
	animated_sprite.play("idle")
	
	# Podłącz timer
	if !cooldown_timer:
		cooldown_timer = Timer.new()
		cooldown_timer.name = "CooldownTimer"
		cooldown_timer.one_shot = true
		add_child(cooldown_timer)
	
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	# Podłącz sygnał animacji
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# Podłącz detektor kolizji
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if !can_bounce:
		return
		
	# Sprawdź czy to gracz
	if body.is_in_group("player") or body.name.begins_with("Player"):
		# Aktywuj trampolinę
		bounce_player(body)
		bounce_sound.play()
		

func bounce_player(player):
	if !can_bounce:
		return
		
	# Dezaktywuj trampolinę na czas cooldownu
	can_bounce = false
	
	# Odtwórz animację skoku
	animated_sprite.play("jump")
	
	# Wyrzuć gracza w górę
	if player is CharacterBody2D:
		player.velocity.y = -bounce_strength
	elif player.has_method("apply_central_impulse"):
		player.apply_central_impulse(Vector2(0, -bounce_strength))
	elif player.has_method("set_linear_velocity"):
		var vel = player.get_linear_velocity()
		vel.y = -bounce_strength
		player.set_linear_velocity(vel)
	
	# Uruchom timer odnowienia
	cooldown_timer.start(cooldown_time)

func _on_animation_finished():
	# Powrót do animacji spoczynkowej po zakończeniu animacji skoku
	if animated_sprite.animation == "jump":
		animated_sprite.play("idle")

func _on_cooldown_timer_timeout():
	# Reset trampoliny
	can_bounce = true
