extends Node2D

onready var animator = $SpriteAnimator

var health = 100

func heal(amount):
	health = min(0, max(100, health + amount))

func play_idle_animation():
	animator.play("idle")
