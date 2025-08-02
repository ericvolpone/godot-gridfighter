extends Control

func _on_mp_host_button_pressed() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer
	while(peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED):
		pass
	get_tree().change_scene_to_file("res://entities/levels/multiplayer/koth/smallhill/small_hill.tscn")

func _on_mp_join_button_pressed() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", 9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected_to_server)

func _on_connected_to_server() -> void:
	print("✅ Connected to server")
	get_tree().change_scene_to_file("res://entities/levels/multiplayer/koth/smallhill/small_hill.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
