extends Node

onready var player_dying_sound = $PlayerDyingSound
onready var rat_dying_sound = $RatDyingSound
onready var secret_reveal_sound = $SecretRevealSound

func play_player_dying_sound():
	player_dying_sound.play()

func play_rat_dying_sound():
	rat_dying_sound.play()

func play_secret_reveal_sound():
	secret_reveal_sound.play();
