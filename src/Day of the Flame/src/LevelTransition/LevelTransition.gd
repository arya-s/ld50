extends Area2D

export(String, FILE, "*.tscn") var next_level = ""

var active = true

func _enter_tree():
	active = true

func _on_LevelTransition_body_entered(body):
	if active and body.is_in_group("player"):
		if next_level != "":
			Utils.change_scene(next_level)
			active = false
