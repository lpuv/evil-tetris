extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("goodbye to " + str(body.name))
	body.set_meta("to_delete", true)
