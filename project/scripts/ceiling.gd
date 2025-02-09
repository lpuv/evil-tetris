extends Area2D

var is_random_gravity = false
var is_fast_gravity = false

func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.visible = true
		body.gravity_scale = 0.0000001
		body.inertia = 0
		
		if is_random_gravity:
			body.gravity_scale = randf_range(0.00001, 10)
			is_random_gravity = false
		elif is_fast_gravity:
			body.gravity_scale = 0.5
			is_fast_gravity = false
	


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.get_meta("is_landed"):
			get_parent().win()
