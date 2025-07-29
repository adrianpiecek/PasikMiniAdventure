extends Node2D

@export var radius: float = 20.0
@export var swing_angle_deg: float = 120.0  # jeśli 360 – obrót pełny
@export var swing_speed: float = 1.0
@export var clockwise: bool = true

@onready var pivot = $Pivot
@onready var ball = $Pivot/Ball
@onready var chain_drawer = $ChainDrawer

var angle := 0.0
var direction := 1
var max_angle_rad := 0.0

func _ready():
	max_angle_rad = deg_to_rad(swing_angle_deg) / 2
	if swing_angle_deg == 360.0:
		direction = 1 if clockwise else -1

func _process(delta):
	if swing_angle_deg >= 360.0:
		# Full circle rotation
		angle += delta * swing_speed * direction
	else:
		# Pendulum motion using sine wave
		angle = max_angle_rad * sin(Time.get_ticks_msec() / 1000.0 * swing_speed)
	
	# Calculate ball position - starting at bottom position
	var actual_angle = PI/2 + angle
	var x = radius * cos(actual_angle)
	var y = radius * sin(actual_angle)
	ball.position = Vector2(x, y)
	
	# Update ball rotation to look correct
	ball.rotation = actual_angle + PI/2
	
	if chain_drawer:
		chain_drawer.draw_chain(Vector2.ZERO, ball.position)
