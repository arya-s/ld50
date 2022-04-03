extends Node

export(String, FILE, "Level_*.tscn") var starting_level

func _ready():
#	VisualServer.set_default_clear_color(Color('10141f'))
	VisualServer.set_default_clear_color(Color('0e151c'))

	get_tree().change_scene(starting_level)
