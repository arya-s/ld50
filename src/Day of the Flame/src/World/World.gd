extends Node2D

onready var fps_label = $FPSLabel
onready var hud = $HUD
onready var player = $Player

func _ready():
	VisualServer.set_default_clear_color(Color('10141f'))
	
func _process(delta):
	fps_label.text = str(Engine.get_frames_per_second())
	
	var fireball_amount = 0 if player.health <= 25 else floor((player.health - player.FIREBALL_COST) / player.FIREBALL_COST)
	hud.set_fireball_amount(fireball_amount)
