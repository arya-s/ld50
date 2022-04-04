extends Node2D

onready var sprite = $Sprite
export(Vector2) var velocity = Vector2.ZERO
var ALIVE = true

func _ready():
	var frame = randi() % sprite.hframes
	sprite.frame = frame
	
	var s = -1 if randf() > 0.5 else 1
	var a = randi() % 4
	sprite.position = Vector2(s * a, 0)

func _process(delta):
	position += velocity * delta

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()

func _on_Hitbox_body_entered(body):
	queue_free()

func _on_Hitbox_area_entered(area):
	queue_free()
