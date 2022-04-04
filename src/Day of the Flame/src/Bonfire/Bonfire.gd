extends Node2D

onready var particles_base = $ParticlesBase
onready var particles_core = $PartcilesCore

export(bool) var ACTIVE = false

func set_active(active):
	ACTIVE = active
	particles_base.emitting = active
	particles_core.emitting = active


func _on_Bonfire_body_entered(body):
	if not ACTIVE and body.is_in_group("player"):
		pass
		#Utils.set_bonfire_active(true)
