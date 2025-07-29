extends CharacterBody2D

enum Direction { LEFT, RIGHT, UP, DOWN }

@export var move_cycle: Array[Direction] = [Direction.LEFT, Direction.RIGHT]
@export var move_speed: float = 300.0
@export var wait_time: float = 0.5
@export var crush_margin: float = 6.0 # jak blisko musi być gracz, by zostać zmiażdżonym
@export var camera_path: NodePath # wskaż ścieżkę do kamery

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_area: Area2D = $HurtArea
@onready var hit_sound = $HitSound

var current_direction_index: int = 0
var moving: bool = false
var last_direction: Direction

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

func _move_to_next():
	moving = true
	sprite.play("blink")
	sprite.play("idle")

func _on_collision(collision: KinematicCollision2D):
	moving = false
	_play_impact_animation()
	hit_sound.play()
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
	if body.name == "Player":
		body.die()
