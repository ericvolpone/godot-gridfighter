extends Control

@onready var lobby_settings: LobbySettings = $LobbySettings
@onready var ip_address_edit: LineEdit = $HBoxContainer/VBoxContainer/IPAddressEdit

func _on_mp_host_button_pressed() -> void:
	lobby_settings.calculate_values()
	if lobby_settings.is_online:
		NetworkManager.host()

	var small_hill: Level = load("res://entities/levels/multiplayer/smallhill/small_hill.tscn").instantiate();
	small_hill.lobby_settings = lobby_settings
	get_tree().root.add_child(small_hill)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = small_hill

func _on_mp_join_button_pressed() -> void:
	var ip_address: String = ip_address_edit.text
	NetworkManager.joined_server.connect(_on_joined_server)
	NetworkManager.join(ip_address)

func _on_joined_server() -> void:
	print("Joined server")
	var small_hill: Level = load("res://entities/levels/multiplayer/smallhill/small_hill.tscn").instantiate();
	get_tree().root.add_child(small_hill)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = small_hill
	NetworkManager.joined_server.disconnect(_on_joined_server)


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
