class_name InGameMenu extends Control

@onready var lobby_code_label: Label = $LobbyCodeLabel

func _ready() -> void:
	print("Lobby Code: " + Noray.oid)
	lobby_code_label.text = Noray.oid

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/menu/home_menu.tscn")

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	var player: Player = get_parent()
	player.is_in_menu = false;
	hide()

func _on_copy_lobby_code_button_pressed() -> void:
	print("Lobby Code: " + Noray.oid)
	DisplayServer.clipboard_set(Noray.oid)
