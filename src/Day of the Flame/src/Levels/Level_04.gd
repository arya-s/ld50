extends "res://src/Levels/Level.gd"

onready var spawn_timer = $SpawnTimer
onready var spawner_1 = $OilSpawner1
onready var spawner_2 = $OilSpawner2
onready var spawner_3 = $OilSpawner3
onready var spawner_4 = $OilSpawner4

var spawners = []

func _ready():
	spawners = [spawner_1, spawner_2, spawner_3, spawner_4]


func _on_SpawnTimer_timeout():
	var spawner = spawners[randi() % spawners.size()]
	spawner.drip()
