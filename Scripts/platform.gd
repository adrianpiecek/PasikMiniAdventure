extends CharacterBody2D

signal player_landed

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		emit_signal("player_landed")
