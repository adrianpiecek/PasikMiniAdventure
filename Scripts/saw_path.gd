extends Path2D

@export var speed: float = 100.0
@export var chain_texture: Texture2D
@export var chain_spacing: float = 16.0  # Odstęp między ogniwami

@onready var follower = $PathFollow2D
@onready var chain = $Chain

func _ready():
	draw_chain()

func _process(delta):
	follower.progress += speed * delta

func draw_chain():
	# Wyczyść poprzednie ogniwa (jeśli rysujemy ponownie)
	for child in chain.get_children():
		child.queue_free()

	var curve = self.curve
	if not curve:
		return

	var length = curve.get_baked_length()
	var t := 0.0
	while t < length:
		var pos = curve.sample_baked(t)
		var next_pos = curve.sample_baked(min(t + 1.0, length))
		var angle = (next_pos - pos).angle()

		var sprite = Sprite2D.new()
		sprite.texture = chain_texture
		sprite.position = pos
		sprite.rotation = angle
		chain.add_child(sprite)

		t += chain_spacing
