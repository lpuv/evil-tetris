extends Control


func _on_start_pressed() -> void:
	Shared.do_music = $MarginContainer/VBoxContainer/do_music.button_pressed
	Shared.sprint_mode = $MarginContainer/VBoxContainer/sprint_mode.button_pressed
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
