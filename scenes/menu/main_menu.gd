extends Control

func _on_mp_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/multiplayer/koth/flat/flat_koth_level.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
