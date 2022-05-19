extends KinematicBody2D

const Fireball = preload("res://src/Fireball/Fireball.tscn")

var player_stats = GameResourceLoader.player_stats
var game_instances = GameResourceLoader.game_instances

var shooting_sounds = [
	preload("res://assets/fireball_1.mp3"),
	preload("res://assets/fireball_2.mp3"),
	preload("res://assets/fireball_3.mp3"),
	preload("res://assets/fireball_4.mp3"),
]

export(int) var ACCELERATION = 1000
export(int) var MAX_SPEED = 90
export(int) var FRICTION = 400
export(int) var JUMP_FORCE = 105
export(int) var JUMP_HORIZONTAL_BOOST = 40
export(int) var GRAVITY = 900
export(int) var HALF_GRAVITY_THRESHOLD = 40
export(int) var FAST_MAX_FALL = 240
export(int) var FAST_MAX_ACCEL = 300
export(int) var MAX_FALL = 160
export(float) var AIR_MULT = 0.65

export(int) var WALL_SLIDE_START_MAX = 20
export(float) var WALL_SLIDE_TIME = 1.2
export(int) var WALL_JUMP_CHECK_DIST = 3
export(float) var WALL_JUMP_FORCE_TIME = 0.16
export(float) var WALL_JUMP_HORIZONTAL_SPEED = MAX_SPEED + JUMP_HORIZONTAL_BOOST
export(float) var WALL_SPEED_RENTENTION_TIME = 0.06

enum {
	LEFT = -1,
	NEUTRAL = 0,
	RIGHT = 1
}

var motion = Vector2.ZERO
var just_jumped = false
var max_fall = 0
var variable_jump_speed = 0
var facing = NEUTRAL
var is_holding = false
var wall_speed_retained = 0

# hack: not actually used
# we have this property so that checks for enemy ALIVE
# won't fail when the hurtbox enters the hibox
var ALIVE = true

var invincible = false setget set_invincible

onready var flame = $Flame
onready var coyote_jump_timer = $CoyoteJumpTimer
onready var variable_jump_timer = $VariableJumpTimer
onready var collider = $Collider
onready var left_wall_ray_cast = $LeftWallRayCast
onready var right_wall_ray_cast = $RightWallRayCast
onready var shoot_cooldown_timer = $ShootCooldownTimer
onready var shooting_position = $ShootingPosition
onready var debug_label = $DebugLabel
onready var jump_sound = $JumpSound
onready var consume_sound = $ConsumeSound
onready var dying_sound = $DyingSound
onready var camera = $Camera
onready var animation_player = $AnimationPlayer
onready var shooting_sound_player = $ShootingSoundPlayer
onready var hurtbox_collider = $Hurtbox/Collider
onready var invincible_animation_player = $InvincibleAnimationPlayer
onready var end_screen = $End

var health_to_collider = {
	100: Vector2(3, 7),
	75: Vector2(3, 5),
	50: Vector2(3, 3),
	25: Vector2(3, 2),
}

signal touched_level_transition(level_transition)
signal boss_died

func _ready():
	shooting_sounds.shuffle()
	
	flame.set_health(player_stats.health)
	player_stats.connect("player_died", self, "_on_died")
	game_instances.player = self
	
	# Place the player in the correct level connection
	if State.level_connection != null:
		for level_transition in get_tree().get_nodes_in_group("level_transition"):
			# find the correct matching connection
			if level_transition != State.ignored_level_transition and level_transition.connection == State.level_connection:
				global_position = level_transition.get_node('ExitPosition').global_position
				break
	# Otherwise we should be spawning at the last spawn point
	elif State.player_spawn_point != null:
		global_position = State.player_spawn_point
		
	facing = State.player_spawm_facing
		
func _exit_tree():
	game_instances.player = null

func _process(delta):
	if player_stats.health < player_stats.HEALTH_CRITICAL_THRESHOLD:
		animation_player.play("low_hp")
	else:
		animation_player.stop(true)
		animation_player.play("reset_from_low_hp")
		
#	debug_label.text = str(player_stats.health)

func _physics_process(delta):
	just_jumped = false

	var input_vector = get_input_vector()
	var direction = sign(input_vector.x)
	
	if direction != 0:
		facing = direction
	
	apply_horizontal_force(input_vector, delta)
	jump_check(input_vector)
	apply_gravity(delta)
	update_animations(input_vector)
	move()
	handle_collisions()
	handle_additional_input()
	update_shooting_position()
	
	
	# Kill the player dark souls style if we fall below the level
	if global_position.y > 220:
		die()
	
func update_animations(input_vector):
	flame.scale.x = facing
	if input_vector.x != 0:
		pass
		#animate("run")
	else:
		flame.play_idle_animation()
		
	# air
	if not is_on_floor():
		var orientation = sign(motion.y)
		if orientation == -1:
			#animate("jump")
			pass
		else:
			pass
			#animate("fall")

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	return input_vector

func apply_horizontal_force(input_vector, delta):
	var mult = 1.0 if is_on_floor() else AIR_MULT
	
	if abs(motion.x) > MAX_SPEED and sign(motion.x) == input_vector.x:
		motion.x = move_toward(motion.x, input_vector.x * MAX_SPEED, FRICTION * mult * delta)
	else:
		motion.x = move_toward(motion.x, input_vector.x * MAX_SPEED, ACCELERATION * mult * delta)

	# Offset flame particles so that they better match the collision box
	flame.move_x(motion.x * facing * 4 * delta)

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	# by supplying the normal of the surface we can automatically
	# detect when the character is on floor using
	# is_on_floor()
	motion = move_and_slide(motion, Vector2.UP)
	
	# landing
	if was_in_air and is_on_floor():
		Controls.rumble_gamepad(Controls.RumbleStrength.Light, Controls.RumbleLength.VeryShort)
	
	# just left ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		coyote_jump_timer.start()

func jump_check(input_vector):
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_jump_timer.time_left > 0:
			jump(input_vector, JUMP_FORCE)
			just_jumped = true
		else:
			if wall_jump_check(RIGHT):
				wall_jump(LEFT, JUMP_FORCE)
				just_jumped = true
			elif wall_jump_check(LEFT):
				wall_jump(RIGHT, JUMP_FORCE)
				just_jumped = true
	elif Input.is_action_just_released("jump") and motion.y < -JUMP_FORCE / 2.0:
		motion.y = -JUMP_FORCE / 2.0

func jump(input_vector, force):
	variable_jump_timer.start()
	motion.x += input_vector.x * JUMP_HORIZONTAL_BOOST
	motion.y = -force
	variable_jump_speed = motion.y
	
	jump_sound.play()
	
func wall_jump(dir, force):
	variable_jump_timer.start()
	motion.x = dir * WALL_JUMP_HORIZONTAL_SPEED
	motion.y = -force
	variable_jump_speed = motion.y
	
	jump_sound.play()
	
func wall_jump_check(dir):
	if dir == LEFT:
		return left_wall_ray_cast.is_colliding()
	elif dir == RIGHT:
		return right_wall_ray_cast.is_colliding()
	
	return false

func apply_gravity(delta: float):
	max_fall = move_toward(max_fall, MAX_FALL, FAST_MAX_ACCEL * delta)
	var mult = 0.5 if abs(motion.y) < HALF_GRAVITY_THRESHOLD and Input.is_action_pressed("jump") else 1.0
	motion.y = move_toward(motion.y, max_fall, GRAVITY * mult * delta)
	
	if (variable_jump_timer.time_left > 0):
		if Input.is_action_pressed("jump"):
			motion.y = min(motion.y, variable_jump_speed)
		else:
			variable_jump_timer.stop()

func update_collider(extents):
	if hurtbox_collider.shape == null || collider.shape.extents.x != extents.x || collider.shape.extents.y != extents.y:
		var collider_shape = RectangleShape2D.new()
		collider_shape.extents = extents
		collider.shape = collider_shape
		collider.position = Vector2(0, -extents.y)
		
		var hurtbox_shape = RectangleShape2D.new()
		hurtbox_shape.extents = extents
		hurtbox_collider.shape = hurtbox_shape
		hurtbox_collider.position = Vector2(0, -extents.y)

func update_collider_for_health():
	if player_stats.health > 75:
		update_collider(health_to_collider[100])
	elif player_stats.health > 50:
		update_collider(health_to_collider[75])
	elif player_stats.health > 25:
		update_collider(health_to_collider[50])
	else:
		update_collider(health_to_collider[25])

func handle_collisions():
	# Relies on speicifically using move_and_slide or mmove_and_slide_with_snap
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		var groups = collider.get_groups()

func heal(amount):
	player_stats.health += amount
	update_collider_for_health()
	flame.set_health(player_stats.health)
	
func _on_HealthDecayTimer_timeout():
	heal(-1)

func handle_additional_input():
	if (player_stats.health > player_stats.HEALTH_LOW_THRESHOLD and
	   Input.is_action_pressed("shoot") and
	   player_stats.fireballs < player_stats.MAX_FIREBALLS and 
	   shoot_cooldown_timer.time_left == 0):
		shoot_fireball()
		

func play_consume_sound():
	consume_sound.play()

func shoot_fireball():
	play_shooting_sound()
	Controls.rumble_gamepad(Controls.RumbleStrength.Medium, Controls.RumbleLength.VeryShort)
	
	player_stats.fireballs += 1
	shoot_cooldown_timer.start()
	
	var fireball = Utils.instance_scene_on_main(Fireball, shooting_position.global_position)
	fireball.move_in_direction(flame.scale.x)
	fireball.connect("fireball_vanished", self, "freeup_fireball")
	
	heal(-player_stats.FIREBALL_COST)

func freeup_fireball():
	player_stats.fireballs -= 1

func update_shooting_position():
	var extents = collider.shape.extents
	shooting_position.position = Vector2(extents.x * flame.scale.x, -extents.y/2 - 2)

func update_camera(room):
	var collider = room.get_node("Collider")
	var size = collider.shape.extents * 2
	
	camera.limit_left = collider.global_position.x - size.x / 2
	camera.limit_top = collider.global_position.y - size.y / 2
	camera.limit_right = camera.limit_left + size.x
	camera.limit_bottom = camera.limit_top + size.y
	
func _on_RoomDetectorLeft_area_entered(room: Area2D):
	update_camera(room)

func _on_RoomDetectorRight_area_entered(room: Area2D):
	update_camera(room)

func die():	
	Global.play_player_dying_sound()
	Controls.rumble_gamepad(Controls.RumbleStrength.Strong, Controls.RumbleLength.Short)
	
	player_stats.reset_player_stats()
	State.ignored_level_transition = null
	State.level_connection = null

	if State.last_bonfire == null:
		Utils.change_scene(State.starting_level)
	else:
		var level = State.bonfires[State.last_bonfire].level
		Utils.change_scene(level)
		
func _on_died():
	die()
	
func low_hp_rumble():
	Controls.rumble_gamepad(Controls.RumbleStrength.Light, Controls.RumbleLength.VeryShort)

func play_shooting_sound():
	var sound = shooting_sounds[randi() % shooting_sounds.size()]
	shooting_sound_player.stream = sound
	shooting_sound_player.play()

func set_invincible(value):
	invincible = value

func _on_Hurtbox_hit(damage):
	if not invincible:
		invincible_animation_player.play("invincible")
		
		# damage > 0 means we took actual damage not got healed
		if damage > 0:
			Controls.rumble_gamepad(Controls.RumbleStrength.Medium, Controls.RumbleLength.Short)
			Global.play_player_hit_sound()
			
		heal(-damage)
		
		
