extends Node

var peer: ENetMultiplayerPeer;

func start_server(port: int) -> void:
	peer = ENetMultiplayerPeer.new();
	peer.create_server(port);
	multiplayer.multiplayer_peer = peer

func start_client(host_name: String, port: int) -> void:
	peer = ENetMultiplayerPeer.new();
	peer.create_client(host_name, port);
	multiplayer.multiplayer_peer = peer
