extends Node2D

var OilDrop = preload("res://src/WaterDrop/OilDrop.tscn")

export(Vector2) var water_velocity = Vector2.DOWN
export(int) var water_speed = 45
export(float) var water_interval = 1.5

onready var timer = $Timer
onready var spawn_point = $SpawnPoint

func drip():
	var drop = Utils.instance_scene_on_main(OilDrop, spawn_point.global_position)
	drop.velocity = water_velocity * water_speed
