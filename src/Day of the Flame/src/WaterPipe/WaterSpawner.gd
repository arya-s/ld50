extends Node2D

var WaterDrop = preload("res://src/WaterDrop/WaterDrop.tscn")

export(Vector2) var water_velocity = Vector2.DOWN
export(int) var water_speed = 45
export(float) var water_interval = 1.5

onready var timer = $Timer
onready var spawn_point = $SpawnPoint

func _ready():
	timer.wait_time = water_interval

func drip():
	var drop = Utils.instance_scene_on_main(WaterDrop, spawn_point.global_position)
	drop.velocity = water_velocity * water_speed

func _on_Timer_timeout():
	drip()
