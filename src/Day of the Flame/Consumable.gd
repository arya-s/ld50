extends Node2D

const Player = preload("res://src/Player/Player.gd")

export(int) var heal_amount = 0


func _on_Collider_body_entered(body):
	print(body.name)
	if body.is_in_group("player"):
		var player = body as Player
		player.heal(heal_amount)
		queue_free()
