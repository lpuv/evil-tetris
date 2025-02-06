extends Area2D

func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		body.visible = true
		body.gravity_scale = 0.0000001
		body.inertia = 0
		print(body.gravity_scale)
