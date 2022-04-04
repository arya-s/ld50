extends Node

const WORLD = preload("res://src/World/World.gd")

func _ready():
	var parent = get_parent()
	
	if parent is WORLD:
		parent.current_level = self
