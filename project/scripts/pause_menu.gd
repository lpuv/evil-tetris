extends Control

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	hide()
	

func resume():
	if not Shared.is_dead:
		get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()
	
func pause():
	show()
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("escape"):
		if get_tree().paused and not Shared.is_dead:
			resume()
		else:
			pause()


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	get_tree().current_scene.prepare_restart()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	testEsc()
