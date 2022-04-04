extends Node2D

export(int) var health = 1
onready var scecret_tile = $SecretTile
onready var reveal_timer = $RevealTimer


func _on_Hurtbox_hit(damage):
	print("secret got hit", health)
	
	if health <= 0:
		scecret_tile.queue_free()
		reveal_timer.start()
	else: 
		health -= 1

func _on_RevealTimer_timeout():
	Global.play_secret_reveal_sound()
	queue_free()
