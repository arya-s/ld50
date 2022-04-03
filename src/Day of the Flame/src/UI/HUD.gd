extends Control

const FireballSprite = preload("res://src/Fireball/FireballSprite.tscn")
onready var fireballs_position = $FireballsPosition

var fireballs = []

func _ready():
	var position = fireballs_position.position
	for i in range(0, 20):
		var fireball = FireballSprite.instance()
		fireball.global_position = position
		fireball.visible = false
		add_child(fireball)
		fireballs.append(fireball)
		position += Vector2(8, 0)
		

func clear():
	for fireball in fireballs:
		fireball.visible = false

func set_fireball_amount(amount):
	clear()
	
	for i in range(0, amount):
		fireballs[i].visible = true
