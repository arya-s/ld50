extends KinematicBody2D

signal fireball_vanished

export(int) var SPEED = 200
export(int) var GRAVITY = 22
export(int) var BOUNCE = -150

var motion = Vector2.ZERO
var direction = 1


func _ready():
	motion.x = direction * SPEED
	
func _physics_process(delta):
	motion.y += GRAVITY
	
	if is_on_wall():
		vanish()
		return

	if is_on_floor():
		motion.y = BOUNCE

	motion = move_and_slide(motion, Vector2.UP)

func vanish():
	emit_signal("fireball_vanished")
	queue_free()
	
func move_in_direction(dir):
	direction = dir
	motion.x = direction * SPEED
	
# warning-ignore:unused_argument
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	vanish()
