extends Control

@onready var lobby_settings: LobbySettings = $LobbySettings
@onready var ip_address_edit: LineEdit = $HBoxContainer/VBoxContainer/IPAddressEdit

var small_hill_scene: PackedScene = load("res://entities/levels/multiplayer/smallhill/small_hill.tscn")
var bridge_scene: PackedScene = load("res://entities/levels/multiplayer/bridge_level/bridge_level.tscn")

func _on_mp_host_button_pressed() -> void:
	lobby_settings.calculate_values()
	if lobby_settings.is_online:
		match lobby_settings.host_type:
			LobbySettings.HostType.NORAY:
				print("Hosting with Noray")
				NetworkManager.host()
			LobbySettings.HostType.LOCAL_HOST:
				print("Hosting with Local Host")
				var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
				peer.create_server(9999)
				multiplayer.multiplayer_peer = peer
				while(peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED):
					pass
				print("Hosting server at:", IP.get_local_addresses())
			_:
				print("Host Type must be selected to host a game")
				return
	else:
		var peer: OfflineMultiplayerPeer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = peer;
		print("Hosting an offline game")

	var small_hill: Level = bridge_scene.instantiate();
	small_hill.lobby_settings = lobby_settings
	get_tree().root.add_child(small_hill)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = small_hill

func _on_mp_join_button_pressed() -> void:
	var ip_address: String = ip_address_edit.text
	match lobby_settings.host_type:
		LobbySettings.HostType.NORAY:
			print("Joining with Noray")
			NetworkManager.joined_server.connect(_on_joined_server)
			NetworkManager.join(ip_address)
		LobbySettings.HostType.LOCAL_HOST:
			print("Joining with Local Host")
			var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
			peer.create_client(ip_address, 9999)
			multiplayer.multiplayer_peer = peer
			multiplayer.connected_to_server.connect(_on_joined_server)
		_:
			print("Must select host type to join")
			return

func _on_joined_server() -> void:
	print("Joined server")
	var small_hill: Level = bridge_scene.instantiate();
	get_tree().root.add_child(small_hill)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = small_hill

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://entities/levels/tutorials/tutorial_level_1.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit();
