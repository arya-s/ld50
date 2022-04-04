extends Node

onready var player_dying_sound = $PlayerDyingSound
onready var rat_dying_sound = $RatDyingSound

func play_player_dying_sound():
	player_dying_sound.play()

func play_rat_dying_sound():
	rat_dying_sound.play()
