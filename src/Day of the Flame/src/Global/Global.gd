extends Node

onready var dying_sound = $DyingSound

func play_dying_sound():
	dying_sound.play()
