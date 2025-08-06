extends Control

@onready var lobby_settings: LobbySettings = $LobbySettings
@onready var ip_address_edit: LineEdit = $HBoxContainer/VBoxContainer/IPAddressEdit

func _on_mp_host_button_pressed() -> void:
	lobby_settings.calculate_values()
	if lobby_settings.is_online:
		var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		peer.create_server(9999)
		multiplayer.multiplayer_peer = peer
		while(peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED):
			pass
		print("Hosting server at:", IP.get_local_addresses())

	var small_hill: Level = load("res://entities/levels/multiplayer/smallhill/small_hill.tscn").instantiate();
	small_hill.lobby_settings = lobby_settings
	get_tree().root.add_child(small_hill)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = small_hill

func _on_mp_join_button_pressed() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var ip_address: String = ip_address_edit.text
	peer.create_client(ip_address, 9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	print("✅ Connected to server")
	get_tree().change_scene_to_file("res://entities/levels/multiplayer/smallhill/small_hill.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
