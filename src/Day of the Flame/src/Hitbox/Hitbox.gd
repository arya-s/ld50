extends Area2D

export(int) var damage = 0


func _on_Hitbox_area_entered(hurtbox):
	hurtbox.emit_signal("hit", damage)
