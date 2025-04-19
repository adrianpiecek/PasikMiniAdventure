extends CharacterBody2D

const SPEED = 200
const JUMP_VELOCITY = -400
const GRAVITY = 900
const COYOTE_TIME = 0.1
const WALL_JUMP_FORCE = Vector2(250, -400)
const WALL_JUMP_LOCK_TIME = 0.2

var coyote_timer = 0.0
var can_double_jump = false
var is_wall_jumping = false
var wall_jump_lock_timer = 0.0
var wall_jump_direction = 0  # -1 = lewo, 1 = prawo

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	var velocity = self.velocity
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var on_floor = is_on_floor()
	var on_wall = is_on_wall_only()

	# === Grawitacja ===
	if not on_floor:
		velocity.y += GRAVITY * delta

	# === Coyote Time ===
	if on_floor:
		coyote_timer = COYOTE_TIME
		can_double_jump = true
	else:
		coyote_timer -= delta

	# === Wall jump blokada ===
	if wall_jump_lock_timer > 0:
		wall_jump_lock_timer -= delta
	else:
		is_wall_jumping = false

	# === Sterowanie poziome (jeśli nie zablokowane) ===
	if not is_wall_jumping:
		velocity.x = direction * SPEED

	# === Wall jump – prawdziwe odbicie od ściany ===
	if Input.is_action_just_pressed("ui_up"):
		if on_floor or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			sprite.play("jump")
		elif on_wall and not on_floor:
			var normal = get_wall_normal()  # np. Vector2(-1, 0) gdy ściana po prawej
			is_wall_jumping = true
			wall_jump_lock_timer = WALL_JUMP_LOCK_TIME
			wall_jump_direction = int(normal.x)
			velocity.x = normal.x * WALL_JUMP_FORCE.x
			velocity.y = WALL_JUMP_FORCE.y
			sprite.play("wall_jump")
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
			sprite.play("double_jump")

	# === Kierunek patrzenia (flip) ===
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# === Animacje ===
	if is_wall_jumping:
		sprite.play("wall_jump")
	elif not on_floor:
		if velocity.y < 0:
			if can_double_jump:
				sprite.play("jump")  # zwykły skok
			else:
				sprite.play("double_jump")  # podwójny skok
		else:
			sprite.play("fall")  # spadanie
	else:
		if abs(velocity.x) > 10:
			sprite.play("run")
		else:
			sprite.play("idle")


	self.velocity = velocity
	move_and_slide()
