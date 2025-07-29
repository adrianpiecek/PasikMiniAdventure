extends CharacterBody2D

const SPEED = 200
const JUMP_VELOCITY = -360
const GRAVITY = 900
const COYOTE_TIME = 0.1
const WALL_JUMP_FORCE = Vector2(200, -360)
const WALL_JUMP_LOCK_TIME = 0.2
const IGNORE_PLATFORM_TIME = 0.2
const WALL_SLIDE_SPEED = 50

var coyote_timer = 0.0
var can_double_jump = false
var is_wall_jumping = false
var wall_jump_lock_timer = 0.0
var wall_jump_direction = 0
var ignore_platform_timer = 0.0
var is_dead = false
var friction = 1.0
var speed_multiplier = 1.0
var max_speed = 400

@onready var sprite = $AnimatedSprite2D
@onready var step_particles = $StepParticles
@onready var double_jump_particles = $DoubleJumpParticles
@onready var wall_slide_particles = $WallSlideParticles

@export var tilemap: TileMap

var surface_properties = {
	"ice": {"friction": 0.1, "speed_multiplier": 1.75},
	"mud": {"friction": 5.0, "speed_multiplier": 0.35},
}
var current_surface = {"friction": 1.0, "speed_multiplier": 1.0}

func _ready() -> void:
		Engine.time_scale = 1

func _physics_process(delta):
	var velocity = self.velocity

	# === Jeśli martwy – tylko spadanie ===
	if is_dead:
		velocity.y += GRAVITY * 2 * delta
		velocity.x = 0  # zablokuj ruch poziomy
		self.velocity = velocity
		move_and_slide()
		return

	# === Kontrola kierunku i stanu ===
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var on_floor = is_on_floor()
	var on_wall = is_on_wall_only()
	var moving_x = velocity.x != 0
	var moving_y = velocity.y != 0
	var hor_arrow_pressed = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")

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
	var base_speed = SPEED
	var friction = current_surface.friction
	var speed_multiplier = current_surface.speed_multiplier

	if not is_wall_jumping:
		var target_speed = direction * base_speed * speed_multiplier
		if friction < 0.5:
			velocity.x = move_toward(velocity.x, target_speed, friction * 1500 * delta)
		else:
			velocity.x = target_speed
	
	if on_wall and velocity.y > WALL_SLIDE_SPEED and hor_arrow_pressed:
		#sprite.play("wall_slide")
		velocity.y = WALL_SLIDE_SPEED
		wall_slide_particles.emitting = true
		if Input.is_action_pressed("ui_right"):
			wall_slide_particles.position = Vector2(14,7)
		elif Input.is_action_pressed("ui_left"):
			wall_slide_particles.position = Vector2(-2,7)
	else:
		wall_slide_particles.emitting = false
	
	# === Skoki ===
	if Input.is_action_just_pressed("ui_up"):
		if on_floor or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			sprite.play("jump")
		elif on_wall and not on_floor:
			var normal = get_wall_normal()
			is_wall_jumping = true
			wall_jump_lock_timer = WALL_JUMP_LOCK_TIME
			wall_jump_direction = int(normal.x)
			velocity.x = normal.x * WALL_JUMP_FORCE.x
			velocity.y = WALL_JUMP_FORCE.y
			sprite.play("wall_jump")
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
			double_jump_particles.emitting = true
			sprite.play("double_jump")

	# === Flip kierunku patrzenia ===
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# === Animacje ===
	if is_wall_jumping:
		sprite.play("wall_jump")
	elif not on_floor:
		if velocity.y < 0:
			if can_double_jump:
				sprite.play("jump")
			else:
				double_jump_particles.emitting = true
				sprite.play("double_jump")
		else:
			sprite.play("fall")
	else:
		if abs(velocity.x) > 10:
			sprite.play("run")
		else:
			sprite.play("idle")		
	
	if moving_x and not moving_y:
		step_particles.emitting = true
	else:
		step_particles.emitting = false
	
	if friction >= 5.0:
		step_particles.modulate = Color(0.0, 0.365, 0.0, 0.647)
	else:
		step_particles.modulate = Color(1.0, 1.0, 1.0, 0.647)
	
	# === Ignorowanie platform po wciśnięciu strzałki w dół ===
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		set_collision_mask_value(2, false)
		ignore_platform_timer = IGNORE_PLATFORM_TIME

	if ignore_platform_timer > 0:
		ignore_platform_timer -= delta
		if ignore_platform_timer <= 0:
			set_collision_mask_value(2, true)
	
	if Input.is_action_pressed("ui_accept"):
		Global.transition_diamond.play_transition(Callable(self, "_restart_level"))
		pass
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("Collided with: ", collision.get_collider().name)
		var collider = collision.get_collider()
		if collider is TileMapLayer:
			var tile_pos = collider.local_to_map(collision.get_position() - collision.get_normal())
			var tile_data = collider.get_cell_tile_data(tile_pos)
			if tile_data:
				if tile_data.get_custom_data("is_deadly"):
					die()
					velocity = Vector2(0, -400)  # Odbicie w górę
					self.velocity = velocity
					break
				current_surface = get_surface_properties(tile_data)
		elif collider.is_in_group("flying_platform"):
			current_surface = {"friction": 1.0, "speed_multiplier": 1.0}
	
	self.velocity = velocity
	move_and_slide()

func get_surface_properties(tile_data: TileData) -> Dictionary:
	if tile_data:
		var surface = tile_data.get_custom_data("surface_type")
		if surface_properties.has(surface):
			return surface_properties[surface]
	return {"friction": 1.0, "speed_multiplier": 1.0}  # domyślne
	
func die():
	if is_dead:
		return

	is_dead = true
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	sprite.play("hit")
	velocity = Vector2(0, -400)  # Odbicie w górę
	self.velocity = velocity
	Engine.time_scale = 0.35

	await get_tree().create_timer(0.45).timeout
	Global.transition_diamond.play_transition(Callable(self, "_restart_level"))

func logical_xor(a: bool, b: bool) -> bool:
	return (a and not b) or (not a and b)

func _restart_level():
	get_tree().reload_current_scene()
