extends Node

onready var hud = $GameUI/HUD
onready var player = $Player


func _process(delta):
	update_hud()
	
func update_hud():
	var fireball_amount = 0 if player.health <= 25 else floor((player.health - 25) / player.FIREBALL_COST) + 1
	hud.set_fireball_amount(fireball_amount)
