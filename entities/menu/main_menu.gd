extends Control

const IP_ADDRESS: String = "localhost"

# Packed Scenes
@onready var small_hill_scene: PackedScene = preload("res://entities/levels/multiplayer/koth/smallhill/small_hill.tscn")

# Child Objects
@onready var host_port_text: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HostPortText
@onready var join_port_text: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/JoinPortText

func _on_mp_button_pressed() -> void:
	var host_port: int = int(host_port_text.text)
	HighLevelNetworkHandler.start_server(42069)
	get_tree().change_scene_to_packed(small_hill_scene)

func _on_mp_join_button_pressed() -> void:
	HighLevelNetworkHandler.start_client(IP_ADDRESS, 42069)
	get_tree().change_scene_to_packed(small_hill_scene)

func _on_ai_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/multiplayer/koth/smallhill/small_hill.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
