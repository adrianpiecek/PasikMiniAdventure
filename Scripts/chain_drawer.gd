extends Node2D

@export var link_texture: Texture2D
@export var link_spacing: float = 8.0

var start_pos: Vector2
var end_pos: Vector2

func draw_chain(start: Vector2, end: Vector2):
	start_pos = start
	end_pos = end
	queue_redraw()

func _draw():
	if not link_texture:
		return
		
	var dir = end_pos - start_pos
	var length = dir.length()
	var norm = dir.normalized()
	var angle = norm.angle()
	var link_count = max(1, int(length / link_spacing))
	var actual_spacing = length / link_count  # Ensure even spacing
	
	for i in range(link_count):
		var pos = start_pos + norm * (i * actual_spacing)
		var offset = link_texture.get_size() / 2
		draw_set_transform(pos, angle, Vector2.ONE)
		draw_texture(link_texture, -offset)
		
	# Reset transform
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
