extends Control

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/menu/home_menu.tscn")

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	var player: Player = get_parent()
	player.is_in_menu = false;
	hide()
