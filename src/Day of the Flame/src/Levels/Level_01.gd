extends "res://src/Levels/Level.gd"

var game_instances = GameResourceLoader.game_instances
onready var initial_spawn_position = $InitialSpawnPosition

func _ready():
	
	call_deferred("add_player")
	
func add_player():
	var player = game_instances.player
	print("Adding player", player)
	add_child(player)
