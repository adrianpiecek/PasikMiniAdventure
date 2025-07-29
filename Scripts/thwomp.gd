extends CharacterBody2D

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var move_cycle: Array[Direction] = [Direction.LEFT, Direction.RIGHT]
@export var move_speed: float = 200.0
@export var wait_time: float = 0.5
@export var crush_margin: float = 6.0 # jak blisko musi być gracz, by zostać zmiażdżonym
@export var camera_path: NodePath # wskaż ścieżkę do kamery

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_area: Area2D = $HurtArea
@onready var camera: Camera2D = get_node(camera_path)

var current_direction_index: int = 0
var moving: bool = false
var last_direction: Direction
var crushing_player: bool = false


func _ready():
	hurt_area.body_entered.connect(_on_hurt_area_body_entered)
	_move_to_next()

func _physics_process(delta):
	if moving:
		last_direction = move_cycle[current_direction_index]
		var velocity = Vector2.ZERO
		
		match last_direction:
			Direction.LEFT:
				velocity.x = -move_speed
			Direction.RIGHT:
				velocity.x = move_speed
			Direction.UP:
				velocity.y = -move_speed
			Direction.DOWN:
				velocity.y = move_speed

		var collision = move_and_collide(velocity * delta)
		if collision:
			_on_collision(collision)

		_move_player_with_thwomp(velocity * delta)
	if moving:
		last_direction = move_cycle[current_direction_index]
		var velocity = Vector2.ZERO
		
		match last_direction:
			Direction.LEFT:
				velocity.x = -move_speed
			Direction.RIGHT:
				velocity.x = move_speed
			Direction.UP:
				velocity.y = -move_speed
			Direction.DOWN:
				velocity.y = move_speed

		var collision = move_and_collide(velocity * delta)
		if collision:
			_on_collision(collision)

func _move_player_with_thwomp(movement: Vector2):
	if crushing_player:
		return # jeśli miażdżymy, nie przesuwamy
	
	for body in hurt_area.get_overlapping_bodies():
		if body.name == "Player":
			if body.has_method("move_and_collide"):
				body.move_and_collide(movement)
			else:
				body.global_position += movement




func _move_to_next():
	moving = true
	sprite.play("idle")

func _on_collision(collision: KinematicCollision2D):
	moving = false
	_crush_check(collision)
	_play_impact_animation()
	_shake_camera()
	await get_tree().create_timer(wait_time).timeout
	current_direction_index = (current_direction_index + 1) % move_cycle.size()
	_move_to_next()

func _play_impact_animation():
	match last_direction:
		Direction.LEFT:
			sprite.play("impact_left")
		Direction.RIGHT:
			sprite.play("impact_right")
		Direction.UP:
			sprite.play("impact_up")
		Direction.DOWN:
			sprite.play("impact_down")

func _on_hurt_area_body_entered(body):
	pass # teraz gracza nie zabijamy tutaj!

func _crush_check(collision: KinematicCollision2D):
	crushing_player = false

	for body in hurt_area.get_overlapping_bodies():
		if body.name == "Player":
			var player_pos = body.global_position
			var thwomp_pos = global_position
			var shape_size = (hurt_area.get_child(0) as CollisionShape2D).shape.size / 2
			var crush_margin = 6.0 # odległość w pikselach, przy której uznajemy "miażdżenie"

			match last_direction:
				Direction.LEFT:
					if (player_pos.x < thwomp_pos.x) and (abs(player_pos.x - (thwomp_pos.x - shape_size.x)) < crush_margin):
						crushing_player = true
						body.die()
				Direction.RIGHT:
					if (player_pos.x > thwomp_pos.x) and (abs(player_pos.x - (thwomp_pos.x + shape_size.x)) < crush_margin):
						crushing_player = true
						body.die()
				Direction.UP:
					if (player_pos.y < thwomp_pos.y) and (abs(player_pos.y - (thwomp_pos.y - shape_size.y)) < crush_margin):
						crushing_player = true
						body.die()
				Direction.DOWN:
					if (player_pos.y > thwomp_pos.y) and (abs(player_pos.y - (thwomp_pos.y + shape_size.y)) < crush_margin):
						crushing_player = true
						body.die()

	
	for body in hurt_area.get_overlapping_bodies():
		if body.name == "Player":
			var player_pos = body.global_position
			var thwomp_pos = global_position
			var shape_size = (hurt_area.get_child(0) as CollisionShape2D).shape.size / 2
			
			match last_direction:
				Direction.LEFT:
					if player_pos.x < thwomp_pos.x and abs(player_pos.y - thwomp_pos.y) < shape_size.y:
						crushing_player = true
						body.die()
				Direction.RIGHT:
					if player_pos.x > thwomp_pos.x and abs(player_pos.y - thwomp_pos.y) < shape_size.y:
						crushing_player = true
						body.die()
				Direction.UP:
					if player_pos.y < thwomp_pos.y and abs(player_pos.x - thwomp_pos.x) < shape_size.x:
						crushing_player = true
						body.die()
				Direction.DOWN:
					if player_pos.y > thwomp_pos.y and abs(player_pos.x - thwomp_pos.x) < shape_size.x:
						crushing_player = true
						body.die()
	for body in hurt_area.get_overlapping_bodies():
		if body.name == "Player":
			var player_pos = body.global_position
			var thwomp_pos = global_position
			var shape_size = (hurt_area.get_child(0) as CollisionShape2D).shape.size / 2 # <-- poprawka
			
			match last_direction:
				Direction.LEFT:
					if player_pos.x < thwomp_pos.x and abs(player_pos.y - thwomp_pos.y) < shape_size.y:
						body.die()
				Direction.RIGHT:
					if player_pos.x > thwomp_pos.x and abs(player_pos.y - thwomp_pos.y) < shape_size.y:
						body.die()
				Direction.UP:
					if player_pos.y < thwomp_pos.y and abs(player_pos.x - thwomp_pos.x) < shape_size.x:
						body.die()
				Direction.DOWN:
					if player_pos.y > thwomp_pos.y and abs(player_pos.x - thwomp_pos.x) < shape_size.x:
						body.die()

func _shake_camera():
	if not camera:
		return
	
	var screen_rect = Rect2(camera.global_position - camera.get_viewport_rect().size / 2, camera.get_viewport_rect().size)
	if screen_rect.has_point(global_position):
		camera.start_screen_shake()
